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
- gQUIC? iQUIC? We all QUIC for yogurt?
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

# Packets out example
```c
  static int
  my_packets_out (void *ctx, const struct lsquic_out_spec *specs,
                                              unsigned n_specs) {
      struct msghdr msg;  memset(&msg, 0, sizeof(msg));
      unsigned n;
      for (n = 0; n < n_specs; ++n) {
          msg.msg_name       = (void *) specs[n].dest_sa;
          msg.msg_namelen    = sizeof(struct sockaddr_in);
          msg.msg_iov        = specs[n].iov;
          msg.msg_iovlen     = specs[n].iovlen;
          if (sendmsg((int) specs[n].peer_ctx, &msg, 0) < 0)
              break;
      }
      return (int) n;
  }
```

# Resuming sending packets
- If ``ea_packets_out`` can't send all packets, engine enters the
  "can't send packets" mode
  - For a second
- Call ``lsquic_engine_send_unsent_packets()`` when sending is
  possible again

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
- There are incoming packets
- A stream is both readable by the user code and the user code wants
  to read from it
- A stream is both writeable by the user code and the user code wants
  to write to it
- User has written to stream outside of ``on_write()`` callbacks (that
  is allowed) and now there are packets ready to be sent
- A timer (pacer, retransmission, idle, etc) has expired
- A control frame needs to be sent out
- A stream needs to be serviced or created

# Required engine callbacks
- Callback to send packets
- Connection and stream callbacks
- ``on_new_conn()``, ``on_read()``, and so on
- Callback to get default TLS context (server only)
- Certificate lookup by SNI (server only)

# Optional callbacks
- HTTP header set processing
- Outgoing packet memory allocation
- Connection ID lifecycle: new, live, and old CIDs
- Shared memory hash

# Engine constructor
- Server or client
- HTTP mode
```c
  /* Return a new engine instance.
   * `flags' is bitmask of LSENG_SERVER and LSENG_HTTP.
   * `api' is required.
   */
  lsquic_engine_t *
  lsquic_engine_new (unsigned flags,
                     const struct lsquic_engine_api *api);
```

# Specifying engine callbacks
- Pass pointer to ``struct lsquic_engine_api``
```c
  struct lsquic_engine_api engine_api = {
      .ea_packets_out     = send_packets_out,
      .ea_packets_out_ctx = sender_ctx,
      .ea_stream_if       = &stream_callbacks,
      .ea_stream_if_ctx   = &some_context,
  };
```

# Stream and connection callbacks
- Specified in ``struct lsquic_stream_if``
- Mandatory callbacks:
  - ``on_new_conn()`` - new connection is created
  - ``on_conn_closed()``
  - ``on_new_stream()``
  - ``on_read()``
  - ``on_write()``
  - ``on_close()``
- Optional callbacks:
  - ``on_goaway_received()``
  - ``on_new_token()``
  - ``on_hsk_done()`` (client only)
  - ``on_zero_rtt_info()`` (client only)

# On new connection
- Server: handshake successful; client: object created
- Chance to create custom per-connection context
```c
  /* Return pointer to per-connection context.  OK to return NULL. */
  static lsquic_conn_ctx_t *
  my_on_new_conn (void *ea_stream_if_ctx, lsquic_conn_t *conn)
  {
    struct some_context *ctx = ea_stream_if_ctx;
    struct my_conn_ctx *my_ctx = my_ctx_new(ctx);
    if (ctx->is_client)
      /* Need a stream to send request */
      lsquic_conn_make_stream(conn);
    return (void *) my_ctx;
  }
```

# On new stream
- Depending on situation, register interest in reading or writing
  - Or just read or write
- Chance to create per-stream context
```c
  /* Return pointer to per-connection context.  OK to return NULL. */
  static lsquic_stream_ctx_t *
  my_on_new_stream (void *ea_stream_if_ctx, lsquic_stream_t *stream) {
      struct some_context *ctx = ea_stream_if_ctx;
      /* Associate some data with this stream: */
      struct my_stream_ctx *stream_ctx
                    = my_stream_ctx_new(ea_stream_if_ctx);
      stream_ctx->stream = stream;
      if (ctx->is_client)
        lsquic_stream_wantwrite(stream, 1);
      return (void *) stream_ctx;
  }
```

# On read
- Read data -- or collect error
```c
  static void
  my_on_read (lsquic_stream_t *stream, lsquic_stream_ctx_t *h) {
      struct my_stream_ctx *my_stream_ctx = (void *) h;
      unsigned char buf[BUFSZ];

      ssize_t nr = lsquic_stream_read(stream, buf, sizeof(buf));
      /* Do something with the data.... */
      if (nr == 0) /* EOF */ {
        lsquic_stream_shutdown(stream, 0);
        lsquic_stream_wantwrite(stream, 1); /* Want to reply */
      }
  }
```

# On write
- If called, you should be able to write *some* bytes
```c
  static void
  my_on_write (lsquic_stream_t *stream, lsquic_stream_ctx_t *h) {
      struct my_stream_ctx *my_stream_ctx = (void *) h;
      ssize_t nw = lsquic_stream_write(stream,
          my_stream_ctx->resp, my_stream_ctx->resp_sz);
      if (nw == my_stream_ctx->resp_sz)
        lsquic_stream_close(stream);
  }
```

# On stream close
- After this, stream will be destroyed, drop all pointers to it
```c
  static void
  my_on_close (lsquic_stream_t *stream, lsquic_stream_ctx_t *h) {
    lsquic_conn_t *conn = lsquic_stream_conn(stream);
    struct my_conn_ctx *my_ctx = lsquic_conn_get_ctx(conn);
    if (!has_more_reqs_to_send(my_ctx)) /* For example */
      lsquic_conn_close(conn);
    free(h);
  }
```

# On connection close
- After this, connection will be destroyed, drop all pointers to it
```c
  static void
  my_on_conn_closed (lsquic_conn_t *conn) {
      struct my_conn_ctx *my_ctx = lsquic_conn_get_ctx(conn);
      struct some_context *ctx = my_ctx->some_context;

      --ctx->n_conns;
      if (0 == ctx->n_conn && (ctx->flags & CLOSING))
          exit_event_loop(ctx);

      free(my_ctx);
  }
```

# Client: making connection
```c
  lsquic_conn_t *
  lsquic_engine_connect (lsquic_engine_t *, enum lsquic_version,
        const struct sockaddr *local_sa,
        const struct sockaddr *peer_sa,
        void *peer_ctx,
        lsquic_conn_ctx_t *conn_ctx,
        const char *hostname,         /* Used for SNI */
        unsigned short max_packet_size,
        const unsigned char *zero_rtt, size_t zero_rtt_len,
        const unsigned char *token, size_t token_sz);
```

# Specifying QUIC version
- There is no version negotiation version in QUIC... yet
- When passed to ``lsquic_engine_connect``, ``N_LSQVER`` means "let
  the engine pick the version"
  - The engine picks the highest it supports, so that's a good
    way to go
```c
enum lsquic_version
{
    LSQVER_043, LSQVER_046, LSQVER_050,   /* Google QUIC */
    LSQVER_ID25, LSQVER_ID27,             /* IETF QUIC */
    /* ...some special entries skipped */
    N_LSQVER
};
```

# Server: additional callbacks
- SSL context and certificate callbacks
```c
  typedef struct ssl_ctx_st * (*lsquic_lookup_cert_f)(
      void *lsquic_cert_lookup_ctx, const struct sockaddr *local,
      const char *sni);

  struct lsquic_engine_api {
    lsquic_lookup_cert_f   ea_lookup_cert;
    void                  *ea_cert_lu_ctx;
    struct ssl_ctx_st *  (*ea_get_ssl_ctx)(void *peer_ctx);
    /* (Other members of the struct are not shown) */
  };
```

# QUIC Tools

- Wireshark
- qvis
