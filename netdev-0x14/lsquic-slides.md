% Programming LSQUIC
% Dmitri Tikhonov
% Netdev 0x14

# About presenter (me)

# Presentation Structure

# Where to get the code

# What is QUIC (keep it short)

# Introducing LSQUIC

# Code example

```c
if (foo)
    bar(1, 2);
```

# History

- *2016*. Goal: add Google QUIC support to LiteSpeed Web Server.
- *2017*. gQUIC support is shipped (Q035); LSQUIC is released on GitHub (client only).
- *2018*. IETF QUIC work begins. LSQUIC is the first functional HTTP/3 server.
- *2019*. LSQUIC 2.0 is released on GitHub (including the server bits). HTTP/3 support is shipped.
- *2020*. HTTP/3 is an RFC. (One can hope.)

# Features
- Latest IETF QUIC and HTTP/3 support, including
- ECN, spin bits, path migration, rebinding
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
- Bidirectional
- Usually corresponds to request/response exchange -- depending on the application protocol
- API tries to mimic socket
- But one can only take it so far

# Packets in
- Single function to feed packets to engine instance
- Specify: datagram, peer and local addresses, ECN value
- Why specify local address

# Packets out
- Callback
- Called during connection processing (explicit call by user)

# When to process connections
- Connections are either tickable immediately or at some future point
- Future point may be a retx, idle, or some other alarm
- Only exception when idle timeout is disabled (on by default)
- Engine knows when to process connections next

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
