#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <algorithm>
#include <vector>
#define BUF_SIZ 1024


#define DEFAULT_IF "enp0s3"
unsigned char dest_mac[6] = {0x08, 0x00, 0x27, 0xfb, 0xbc, 0x42};
unsigned char target_mac[6] = {0x08, 0x00, 0x27, 0xf1, 0x3f, 0x3c};
int printall = 1;

void print_packet(std::vector<uint8_t> *packet)
{
    uint64_t size = packet->size();
    for (uint64_t i = 0; i < size; i++)
    {
        printf("%u ", (unsigned char)packet->at(i));
    }
    printf("\n");
}

int prepare_transmitter()
{
    int sockfd; // Socket
    // Open socket
    if ((sockfd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) == -1)
    {
        perror("socket() error");
        if (errno == EACCES)
            printf(" (EACCES)\n");
        if (errno == EAFNOSUPPORT)
            printf(" (EAFNOSUPPORT)\n");
        return -1;
    }
    return sockfd;
}

void build_payload(unsigned char *packet_data, uint64_t *latest_symbol_id, uint64_t *num_coded_symbols, uint64_t *seed, std::vector<uint8_t> *packet)
{
    memcpy(&packet_data[0], latest_symbol_id, 8);                           // latest packet
    memcpy(&packet_data[8], num_coded_symbols, 8);                          // window_size
    memcpy(&packet_data[16], seed, 8);                                      // seed
    std::copy(packet->begin(), packet->end(), (uint8_t *)&packet_data[24]); 
    if (printall)
    {
        printf("latest packet: %lu \n", *latest_symbol_id);
        printf("window size: %lu \n", *num_coded_symbols);
        printf("seed: %lu \n\n", *seed);
        printf("Coded Pkt: \n");
        print_packet(packet);
        printf("\n\n");
    }
}

void transmit_pkt(unsigned char *packet_data, uint64_t tx_data_size, int sockfd)
{
    //socket transmission
    char ifName[IFNAMSIZ] = DEFAULT_IF; // Interfacename
    struct ifreq if_idx;                // Datastructure for interface index
    struct ifreq if_mac;                // Datastructure for MAC address
    unsigned char hwaddr[6];            // current MAC address
    char sendbuf[BUF_SIZ];              // transmit buffer, including header, data
    struct sockaddr_ll socket_address;  // for sendto()
    int index;                          // interface index

    struct ether_header *eh = (struct ether_header *)sendbuf;
    unsigned char *data = (unsigned char *)(sendbuf + sizeof(struct ether_header));


    strcpy(ifName, DEFAULT_IF);
    memset(&if_idx, 0, sizeof(struct ifreq));
    strncpy(if_idx.ifr_name, ifName, IFNAMSIZ - 1);
    if (ioctl(sockfd, SIOCGIFINDEX, &if_idx) < 0)
    {
        perror("SIOCGIFINDEX");
        return;
    }
    index = if_idx.ifr_ifindex;

    memset(&if_mac, 0, sizeof(struct ifreq));
    strncpy(if_mac.ifr_name, ifName, IFNAMSIZ - 1);
    if (ioctl(sockfd, SIOCGIFHWADDR, &if_mac) < 0)
    {
        perror("SIOCGIFHWADDR");
        return;
    }

    memcpy(hwaddr, if_mac.ifr_hwaddr.sa_data, 6);


    memset(sendbuf, 0, BUF_SIZ);
    // Ethernet header
    memcpy(eh->ether_shost, hwaddr, 6);   // Source address
    memcpy(eh->ether_dhost, dest_mac, 6); // Dest address
    eh->ether_type = htons(ETH_P_IP);     // Ethertype field (does this matter as long as I only use ethernet packets?)

    memcpy(data, packet_data, tx_data_size);
    // prepare sockaddr_ll
    memset(&socket_address, 0, sizeof(struct sockaddr_ll));
    socket_address.sll_family = PF_PACKET;         // RAW communication
    socket_address.sll_protocol = htons(ETH_P_IP); // Higher layer protocol (does this matter as long as I only use ethernet packets?)
    socket_address.sll_hatype = ARPHRD_ETHER;      // Ethernet
    socket_address.sll_pkttype = PACKET_OTHERHOST; //

    socket_address.sll_ifindex = index;                  // Interface index
    socket_address.sll_halen = ETH_ALEN;                 // Address length
    memcpy(socket_address.sll_addr, dest_mac, ETH_ALEN); // Dest MAC
    printf("\n ");
    for (int i = 0; i < 14; i++)
    {
        printf("%u ", sendbuf[i]);
    }
    printf("\n ");
    for (int i = 14; i < 22; i++)
    {
        printf("%u ", sendbuf[i]);
    }
    printf("\n ");
    for (int i = 22; i < 30; i++)
    {
        printf("%u ", sendbuf[i]);
    }
    printf("\n ");
    // Send packet:
    //		eth header
    //			MAC dest, MAC source, Ethernet type
    //		Payload
    //			Current Pkt Number, Pkt amount, NC seed, NC payload
    // 		checksum crc is auto done by hardware
    //if (sendto(sockfd, sendbuf, ETH_HLEN + strlen((char*)packet_data), 0,
    if (sendto(sockfd, sendbuf, ETH_HLEN + tx_data_size, 0,
               (struct sockaddr *)&socket_address, sizeof(struct sockaddr_ll)) < 0)
        printf("sendto() err\n");

    printf("-------------------------------------------");
    printf("\n");
}

void prepare_receiver(int *sockfd, unsigned char *dest_m, unsigned char *target_m)
{
    char ifName[IFNAMSIZ] = DEFAULT_IF; // Interfacename
    struct ifreq if_idx;                // Datastructure for interface index
    struct ifreq if_mac;                // Datastructure for MAC address
    unsigned char hwaddr[6];            // current MAC address
    struct sockaddr_ll socket_address;  // for sendto()
    int index;                          // interface index
    dest_m[0] = dest_mac[0];
    dest_m[1] = dest_mac[1];
    dest_m[2] = dest_mac[2];
    dest_m[3] = dest_mac[3];
    dest_m[4] = dest_mac[4];
    dest_m[5] = dest_mac[5];
    target_m[0] = target_mac[0];
    target_m[1] = target_mac[1];
    target_m[2] = target_mac[2];
    target_m[3] = target_mac[3];
    target_m[4] = target_mac[4];
    target_m[5] = target_mac[5];
    strcpy(ifName, DEFAULT_IF);
    // Open socket
    if ((*sockfd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) == -1)
    {
        perror("socket() error");
        if (errno == EACCES)
            printf(" (EACCES)\n");
        if (errno == EAFNOSUPPORT)
            printf(" (EAFNOSUPPORT)\n");
        return;
    }

    // Get interface index
    memset(&if_idx, 0, sizeof(struct ifreq));
    strncpy(if_idx.ifr_name, ifName, IFNAMSIZ - 1);
    if (ioctl(*sockfd, SIOCGIFINDEX, &if_idx) < 0)
    {
        perror("SIOCGIFINDEX");
        return;
    }
    index = if_idx.ifr_ifindex;

    // Get the MAC address of the interface
    memset(&if_mac, 0, sizeof(struct ifreq));
    strncpy(if_mac.ifr_name, ifName, IFNAMSIZ - 1);

    if (ioctl(*sockfd, SIOCGIFHWADDR, &if_mac) < 0)
    {
        perror("SIOCGIFHWADDR");
        return;
    }
    memcpy(hwaddr, if_mac.ifr_hwaddr.sa_data, 6);

    // prepare sockaddr_ll
    memset(&socket_address, 0, sizeof(struct sockaddr_ll));
    socket_address.sll_family = PF_PACKET;         // RAW communication
    socket_address.sll_protocol = htons(ETH_P_IP); // Higher layer protocol (does this matter as long as I only use ethernet packets?)
    socket_address.sll_hatype = ARPHRD_ETHER;      // Ethernet
    socket_address.sll_pkttype = PACKET_OTHERHOST; //
    socket_address.sll_ifindex = index;            // Interface index
    socket_address.sll_halen = ETH_ALEN;           // Address length
}
