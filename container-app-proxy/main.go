package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net"
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

func main() {
	ctx := context.Background()

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		log.Fatalf("create credential: %v", err)
	}

	_, err = cred.GetToken(ctx, policy.TokenRequestOptions{
		Scopes: []string{"https://management.azure.com/.default"},
	})
	if err != nil {
		log.Fatalf("authenticate: %v", err)
	}

	subIDs, err := listEnabledSubscriptions(ctx, cred)
	if err != nil {
		log.Fatalf("list subscriptions: %v", err)
	}
	if len(subIDs) == 0 {
		log.Fatal("no enabled subscriptions found")
	}

	for _, subID := range subIDs {
		if err := processSubscription(ctx, cred, subID); err != nil {
			log.Printf("subscription %s error: %v", subID, err)
		}
	}
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

func processSubscription(ctx context.Context, cred azcore.TokenCredential, subID string) error {
	client, err := armcontainerinstance.NewContainerGroupsClient(subID, cred, nil)
	if err != nil {
		return err
	}

	pager := client.NewListPager(nil)
	fmt.Printf("Subscription: %s\n", subID)

	for pager.More() {
		page, err := pager.NextPage(ctx)
		if err != nil {
			return err
		}

		for _, cg := range page.Value {
			if cg == nil || cg.ID == nil || cg.Name == nil {
				continue
			}

			rg := resourceGroupFromID(*cg.ID)
			name := *cg.Name
			if rg == "" {
				log.Printf("skip %s: cannot parse resource group", name)
				continue
			}

			// Fresh read with instance details
			getResp, err := client.Get(ctx, rg, name, nil)
			if err != nil {
				log.Printf("get %s/%s failed: %v", rg, name, err)
				continue
			}
			group := getResp.ContainerGroup

			// 0) get port
			port, err := pickPort(group)
			if err != nil {
				log.Printf("%s/%s: no usable port: %v", rg, name, err)
				continue
			}

			// 1) state
			state := currentState(group)
			fmt.Printf("- %s/%s state=%s port=%d\n", rg, name, state, port)

			// 2) start if stopped
			if isStoppedLike(state) {
				fmt.Printf("  starting %s/%s...\n", rg, name)
				poller, err := client.BeginStart(ctx, rg, name, nil)
				if err != nil {
					log.Printf("  start failed for %s/%s: %v", rg, name, err)
					continue
				}
				_, err = poller.PollUntilDone(ctx, &runtime.PollUntilDoneOptions{Frequency: 10 * time.Second})
				if err != nil {
					log.Printf("  start poll failed for %s/%s: %v", rg, name, err)
					continue
				}

				if err := waitUntilRunning(ctx, client, rg, name, 5*time.Minute); err != nil {
					log.Printf("  wait running failed for %s/%s: %v", rg, name, err)
					continue
				}
			}

			// Refresh and probe endpoint
			getResp, err = client.Get(ctx, rg, name, nil)
			if err != nil {
				log.Printf("refresh get %s/%s failed: %v", rg, name, err)
				continue
			}
			group = getResp.ContainerGroup

			host, err := resolvePrivateHost(group)
			if err != nil {
				log.Printf("%s/%s: no internal host/ip: %v", rg, name, err)
				continue
			}

			// 3) check instance port response (TCP for private networking)
			if err := checkTCP(host, port, 20*time.Second); err != nil {
				log.Printf("  tcp check failed %s/%s (%s:%d): %v", rg, name, host, port, err)
				log.Printf("  note: run this from a network with route to the private endpoint (same VNet/peered/VPN).")
				continue
			}

			fmt.Printf("  OK %s/%s reachable at %s:%d\n", rg, name, host, port)
		}
	}
	return nil
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