% Programming LSQUIC
% Dmitri Tikhonov
% Netdev 0x14

# About presenter
- Have programmed many things
- Doing QUIC for last 3.5 years
- Participate in IETF QUIC standardization

# Presentation outline
- Introduction
- LSQUIC history, features, and architecture
- Using API
  - Objects: engines, connections, streams
  - Sending and receiving packets
  - Instantiation and callbacks
- Bonus section, time permitting

# Where to get the code
- You can follow along
- Compile the code while I talk about architecture
- Tags listed on bottom of slides

```bash
git clone https://github.com/litespeedtech/lsquic-tutorial
# This pulls in BoringSSL and ls-qpack
git submodule update --init
# Tested on Ubuntu
cmake .
make
```

# What is QUIC (keep it short)
- Why: Ossification
- Began as HTTP/2 over UDP
- Who: First Google, now everyone:
  - LiteSpeed Technologies, Microsoft, Apple, Facebook, Akamai, and others
- General-purpose transport protocol
- Killer feature: HTTP/3 (end of 2020)
- Experimental: datagrams, multipath, DNS-over-QUIC, NETCONF-over-QUIC,
  and so on
- Future: bright

# Which QUIC do you mean?
- Google QUIC vs IETF QUIC
- gQUIC? uQUIC? iQUIC for yogurt?
- Google QUIC is on the way out
- In the slides that follow, "QUIC" means "IETF QUIC"

# Introducing LSQUIC
- Began as proprietary, then open-sourced
- Vanilla C
- Minimal dependencies
- Flexibility
- Performance

# History
- *2016*. Goal: add Google QUIC support to LiteSpeed Web Server.
- *2017*. gQUIC support is shipped (Q035); LSQUIC is released on GitHub (client only).
- *2018*. IETF QUIC work begins. LSQUIC is the first functional HTTP/3 server.
- *2019*. LSQUIC 2.0 is released on GitHub (including the server bits). HTTP/3 support is shipped.
- *2020*. HTTP/3 is an RFC. (One can hope.)

# Features
- Latest IETF QUIC and HTTP/3 support, including
  - ECN, spin bits, path migration, NAT rebinding
  - Push promises, key updates
  - Several experimental extensions
- Google QUIC versions Q043, Q046 (what Chrome currently uses), and Q050
- Many, many knobs to play with

# Architecture
- Bring your own event loop.
- Bring your own networking.
- Bring your own TLS context.
- Scalable connection management.

# Objects
- Engine
- Connection
- Stream

# Engine
- Client mode *or* server mode
- If need both, instantiate two
- HTTP mode

# Connection
- Client initiates connection; object created before handshake is successful.
- Server: by the time user code gets the connection object, the handshake has already been completed
- Can have many streams during lifetime

# Stream
- Belongs to a connection
- Bidirectional
- Usually corresponds to request/response exchange -- depending on
  the application protocol
- API tries to mimic socket
  - But one can only take it so far

# Packets in
- Single function to feed packets to engine instance
- Specify: datagram, peer and local addresses, ECN value
- ``peer_ctx`` is associated with peer address: it is passed to
  send packets function.

```c
  /*  0: processed by real connection
   *  1: handled
   * -1: error: invalid arguments, malloc failure
   */
  int
  lsquic_engine_packet_in (lsquic_engine_t *,
      const unsigned char *udp_payload, size_t sz,
      const struct sockaddr *sa_local,
      const struct sockaddr *sa_peer,
      void *peer_ctx, int ecn);
```

# Why specify local address
- Becomes source address on outgoing packets
  - Important in multihomed configuration
- Path change detection
  - QUIC sends special frames to validate path

# Packets out
- Callback
- Called during connection processing (explicit call by user)

```c
  /* Returns number of packets successfully sent out or -1 on error.
   *
   * If not all packets could be sent, call
   * lsquic_engine_send_unsent_packets() when can send again.
   */
  typedef int (*lsquic_packets_out_f)(
      void                          *packets_out_ctx,
      const struct lsquic_out_spec  *out_spec,
      unsigned                       n_packets_out
  );
```

# Outgoing packet specification
- Why ``iovec``?
  - UDP packet can contain more than one QUIC packet
  - Packet coalescing

```c
  struct lsquic_out_spec
  {
      struct iovec          *iov;
      size_t                 iovlen;
      const struct sockaddr *local_sa;
      const struct sockaddr *dest_sa;
      void                  *peer_ctx;
      int                    ecn; /* 0 - 3; see RFC 3168 */
  };
```

# When to process connections
- Connections are either tickable immediately or at some future point
- Future point may be a retransmission, idle, or some other alarm
- Only exception when idle timeout is disabled (on by default)
- Engine knows when to process connections next

```c
  /* Returns true if there are connections to be processed, in
   * which case `diff' is set to microseconds from current time.
   */
  int
  lsquic_engine_earliest_adv_tick (lsquic_engine_t *, int *diff);
```

# Tickable connection
- There are incoming packets;
- A stream is both readable by the user code and the user code wants to read from it;
- A stream is both writeable by the user code and the user code wants to write to it;
- User has written to stream outside of on_write() callbacks (that is allowed) and now there are packets ready to be sent;
- A timer (pacer, retransmission, idle, etc) has expired;
- A control frame needs to be sent out;
- A stream needs to be serviced or created

# Resuming sending packets

# Required engine callbacks
- Callback to send packets
- Connection and stream callbacks
- on_new_conn(), on_read(), and so on
- Callback to get default TLS context (server only)
- Certificate lookup by SNI (server only)

# Optional callbacks
- HTTP header set processing
- Outgoing packet memory allocation
- Connection ID lifecycle: new, live, and old CIDs
- Shared memory hash

# Engine constructor

- Server or client
- HTTP

# QUIC Tools

- Wireshark
- qvis
