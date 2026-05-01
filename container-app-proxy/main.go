package main

import (
	"context"
	"errors"
	"log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/policy"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/runtime"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerinstance/armcontainerinstance"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armsubscriptions"
)

func inf(format string, args ...any) {
	log.Printf("[INF] "+format, args...)
}

func errf(format string, args ...any) {
	log.Printf("[ERR] "+format, args...)
}

func errFatalf(format string, args ...any) {
	log.Fatalf("[ERR] "+format, args...)
}

type app struct {
	cred   azcore.TokenCredential
	subIDs []string
}

type proxyTarget struct {
	subscriptionID string
	resourceGroup  string
	name           string
	host           string
	port           int32
}

func main() {
	ctx := context.Background()

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		errFatalf("create credential: %v", err)
	}

	_, err = cred.GetToken(ctx, policy.TokenRequestOptions{
		Scopes: []string{"https://management.azure.com/.default"},
	})
	if err != nil {
		errFatalf("authenticate: %v", err)
	}

	subIDs, err := listEnabledSubscriptions(ctx, cred)
	if err != nil {
		errFatalf("list subscriptions: %v", err)
	}
	if len(subIDs) == 0 {
		errFatalf("no enabled subscriptions found")
	}

	application := &app{
		cred:   cred,
		subIDs: subIDs,
	}

	listenAddr := listenAddr()
	inf("listening on %s", listenAddr)

	server := &http.Server{
		Addr:              listenAddr,
		Handler:           application,
		ReadHeaderTimeout: 10 * time.Second,
	}

	err = server.ListenAndServe()
	if err != nil && !errors.Is(err, http.ErrServerClosed) {
		errFatalf("serve http: %v", err)
	}
}

func (a *app) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(context.Background(), 6*time.Minute)
	defer cancel()

	target, err := a.findTarget(ctx)
	if err != nil {
		http.Error(w, "no available container instance", http.StatusBadGateway)
		errf("select target for %s %s failed: %v", r.Method, r.URL.Path, err)
		return
	}

	inf("proxy %s %s -> %s/%s (%s:%d)", r.Method, r.URL.Path, target.resourceGroup, target.name, target.host, target.port)
	proxyToTarget(w, r, target)
}

func (a *app) findTarget(ctx context.Context) (*proxyTarget, error) {
	var firstErr error

	for _, subID := range a.subIDs {
		target, err := findSubscriptionTarget(ctx, a.cred, subID)
		if err == nil {
			return target, nil
		}
		if firstErr == nil {
			firstErr = err
		}
		errf("subscription %s has no proxy target: %v", subID, err)
	}

	if firstErr == nil {
		firstErr = errors.New("no candidate container groups found")
	}
	return nil, firstErr
}

func proxyToTarget(w http.ResponseWriter, r *http.Request, target *proxyTarget) {
	targetURL := &url.URL{
		Scheme: "http",
		Host:   net.JoinHostPort(target.host, strconv.Itoa(int(target.port))),
	}

	proxy := httputil.NewSingleHostReverseProxy(targetURL)
	proxy.ErrorHandler = func(rw http.ResponseWriter, req *http.Request, err error) {
		errf("proxy %s/%s failed: %v", target.resourceGroup, target.name, err)
		http.Error(rw, "upstream request failed", http.StatusBadGateway)
	}
	proxy.ServeHTTP(w, r)
}

func listenAddr() string {
	port := strings.TrimSpace(os.Getenv("HTTP_PORT"))
	if port == "" {
		port = "8080"
	}
	if strings.HasPrefix(port, ":") {
		return port
	}
	return ":" + port
}

func listEnabledSubscriptions(ctx context.Context, cred azcore.TokenCredential) ([]string, error) {
	client, err := armsubscriptions.NewClient(cred, nil)
	if err != nil {
		return nil, err
	}
	pager := client.NewListPager(nil)

	var ids []string
	for pager.More() {
		page, err := pager.NextPage(ctx)
		if err != nil {
			return nil, err
		}
		for _, s := range page.Value {
			if s == nil || s.SubscriptionID == nil || *s.SubscriptionID == "" {
				continue
			}
			if s.State != nil && *s.State == armsubscriptions.SubscriptionStateEnabled {
				ids = append(ids, *s.SubscriptionID)
			}
		}
	}
	return ids, nil
}

func findSubscriptionTarget(ctx context.Context, cred azcore.TokenCredential, subID string) (*proxyTarget, error) {
	client, err := armcontainerinstance.NewContainerGroupsClient(subID, cred, nil)
	if err != nil {
		return nil, err
	}

	pager := client.NewListPager(nil)

	for pager.More() {
		page, err := pager.NextPage(ctx)
		if err != nil {
			return nil, err
		}

		for _, cg := range page.Value {
			if cg == nil || cg.ID == nil || cg.Name == nil {
				continue
			}

			rg := resourceGroupFromID(*cg.ID)
			name := *cg.Name
			if rg == "" {
				errf("skip %s: cannot parse resource group", name)
				continue
			}

			getResp, err := client.Get(ctx, rg, name, nil)
			if err != nil {
				errf("get %s/%s failed: %v", rg, name, err)
				continue
			}
			group := getResp.ContainerGroup

			port, err := pickPort(group)
			if err != nil {
				continue
			}

			state := currentState(group)

			if isStoppedLike(state) {
				inf("starting %s/%s...", rg, name)
				poller, err := client.BeginStart(ctx, rg, name, nil)
				if err != nil {
					errf("start failed for %s/%s: %v", rg, name, err)
					continue
				}
				_, err = poller.PollUntilDone(ctx, &runtime.PollUntilDoneOptions{Frequency: 10 * time.Second})
				if err != nil {
					errf("start poll failed for %s/%s: %v", rg, name, err)
					continue
				}

				if err := waitUntilRunning(ctx, client, rg, name, 5*time.Minute); err != nil {
					errf("wait running failed for %s/%s: %v", rg, name, err)
					continue
				}
			}

			getResp, err = client.Get(ctx, rg, name, nil)
			if err != nil {
				errf("refresh get %s/%s failed: %v", rg, name, err)
				continue
			}
			group = getResp.ContainerGroup

			if !strings.EqualFold(currentState(group), "Running") {
				continue
			}

			host, err := resolvePrivateHost(group)
			if err != nil {
				continue
			}

			return &proxyTarget{
				subscriptionID: subID,
				resourceGroup:  rg,
				name:           name,
				host:           host,
				port:           port,
			}, nil
		}
	}

	return nil, errors.New("no reachable container group found")
}

func pickPort(group armcontainerinstance.ContainerGroup) (int32, error) {
	// Prefer exposed group IP port
	if group.Properties != nil && group.Properties.IPAddress != nil && len(group.Properties.IPAddress.Ports) > 0 {
		p := group.Properties.IPAddress.Ports[0]
		if p != nil && p.Port != nil {
			return *p.Port, nil
		}
	}
	// Fallback to first container port
	if group.Properties != nil {
		for _, c := range group.Properties.Containers {
			if c == nil || c.Properties == nil || len(c.Properties.Ports) == 0 {
				continue
			}
			cp := c.Properties.Ports[0]
			if cp != nil && cp.Port != nil {
				return *cp.Port, nil
			}
		}
	}
	return 0, errors.New("no port found")
}

func currentState(group armcontainerinstance.ContainerGroup) string {
	if group.Properties != nil && group.Properties.InstanceView != nil && group.Properties.InstanceView.State != nil {
		return strings.TrimSpace(*group.Properties.InstanceView.State)
	}
	return "Unknown"
}

func isStoppedLike(state string) bool {
	s := strings.ToLower(strings.TrimSpace(state))
	return s == "stopped" || s == "terminated" || s == "succeeded" || s == "failed"
}

func waitUntilRunning(ctx context.Context, client *armcontainerinstance.ContainerGroupsClient, rg, name string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		resp, err := client.Get(ctx, rg, name, nil)
		if err == nil {
			st := currentState(resp.ContainerGroup)
			if strings.EqualFold(st, "Running") {
				return nil
			}
		}
		time.Sleep(5 * time.Second)
	}
	return errors.New("timeout waiting for Running")
}

func resolvePrivateHost(group armcontainerinstance.ContainerGroup) (string, error) {
	if group.Properties == nil || group.Properties.IPAddress == nil {
		return "", errors.New("no ipAddress config")
	}

	ip := group.Properties.IPAddress
	// For private scenarios, IP is usually the safest probe target.
	if ip.IP != nil && *ip.IP != "" {
		return *ip.IP, nil
	}
	// FQDN might work with private DNS.
	if ip.Fqdn != nil && *ip.Fqdn != "" {
		return *ip.Fqdn, nil
	}
	return "", errors.New("no private IP/FQDN found")
}

func checkTCP(host string, port int32, timeout time.Duration) error {
	addr := net.JoinHostPort(host, strconv.Itoa(int(port)))
	conn, err := net.DialTimeout("tcp", addr, timeout)
	if err != nil {
		return err
	}
	_ = conn.Close()
	return nil
}

func resourceGroupFromID(id string) string {
	parts := strings.Split(id, "/")
	for i := 0; i < len(parts)-1; i++ {
		if strings.EqualFold(parts[i], "resourceGroups") {
			return parts[i+1]
		}
	}
	return ""
}
