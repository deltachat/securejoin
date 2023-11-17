.. raw:: latex

   \pagestyle{plain}
   \cfoot{securejoin \securejoinrelease}

Introduction
============

This document documents and discusses SecureJoin protocols as implemented
by the `Delta Chat messenger <https://delta.chat>`_.
In particular, this document considers how to secure Autocrypt_-capable mail apps
against active network attackers.
Autocrypt aims to achieve convenient end-to-end encryption of e-mail.
The Level 1 Autocrypt specification offers users opt-in e-mail encryption,
but only considers passive adversaries.
Active network adversaries,
who could, for example,
tamper with the Autocrypt header during e-mail message transport,
are not considered in the Level 1 specification.
Yet,
such active attackers might undermine the security of Autocrypt.
Therefore,
we present and discuss SecureJoin as a new practically usable
way to prevent and detect active network attacks
against Autocrypt_-capable mail apps.

This document reflects the current state of implementation (Delta Chat app version 1.42)
and may evolve in the future
to address user feedback, implementation and security considerations.
To design SecureJoin protocols,
we consider usability, cryptographic and implementation aspects simultaneously,
because they constrain and complement each other.
Note that the basis for SecureJoin protocols was laid in the first two sections of
`CounterMitm <https://countermitm.readthedocs.io/en/latest/>`_
which was created by reseachers of NEXTLEAP,
a 2016-2018 project on privacy and decentralized messaging,
funded through the EU Horizon 2020 programme.


Attack model and terminology
++++++++++++++++++++++++++++

We consider a *network adversary* that can read, modify, and create
network messages.
Examples of such an adversary are an ISP, an e-mail provider, an AS,
or an eavesdropper on a wireless network.
The goal of the adversary is to i) read the content of messages, ii)
impersonate peers -- communication partners, and iii) to learn who communicates
with whom.
To achieve these goals,
an active adversary might try, for example,
to perform a machine-in-the-middle attack on the key exchange protocol
between peers.

To enable secure key-exchange and key-verification between peers,
we assume that peers have access to a *out-of-band*
communication channel that cannot be observed or manipulated by the adversary.
More concretely we expect them to be able
to transfer a small amount of data via a QR-code confidentially.

Targeted attacks on end devices or the out-of-band channels
can break our assumptions
and therefore the security properties of the protocols described.
In particular
the ability to observe QR-codes in the scan process
(for example through CCTV or by getting access to print outs)
will allow impersonation attacks.
Additional measures can
relax the security requirements for the *out-of-band* channel
to also work under a threat of observation.

Passive attackers such as service providers can still learn who
communicates with whom at what time and the approximate size of the messages.
We recommend using additional meassures such as encrypting the subject
to prevent further data leakage.
This is beyond the scope of this document though.

Because peers learn the content of the messages,
we assume that all peers are honest.
They do not collaborate with the adversary and follow the protocols described in this document.

Problems of current key-verification techniques
+++++++++++++++++++++++++++++++++++++++++++++++

An important aspect of secure end-to-end (e2e) encryption is the verification of
a peer's key.
In existing e2e-encrypting messengers,
users perform key verification by triggering two fingerprint verification workflows:
each of the two peers shows and reads the other's key fingerprint
through a trusted channel (often a QR code show+scan).

We observe the following issues with these schemes:

- The schemes require that both peers start the verification workflow to assert
  that both of their encryption keys are not manipulated.
  Such double work has an impact on usability.

- In the case of a group, every peer needs to verify keys with each group member to
  be able to assert that messages are coming from and are encrypted to the true keys of members.
  A peer that joins a group of size :math:`N`
  must perform :math:`N` verifications.
  Forming a group of size :math:`N` therefore requires
  :math:`N(N-1) / 2` verifications in total.
  Thus this approach is impractical even for moderately sized groups.

- The verification of the fingerprint only checks the current keys.
  Since protocols do not store any historical information about keys,
  the verification can not detect if there was a past temporary
  MITM-exchange of keys (say the network adversary
  exchanged keys for a few weeks but changed back to the "correct" keys afterwards).

- Users often fail to distinguish Lost/Reinstalled Device events from
  Machine-in-the-Middle (MITM) attacks, see for example `When Signal hits the Fan
  <https://eurousec.secuso.org/2016/presentations/WhenSignalHitsFan.pdf>`_.


Integrating key verification with general workflows
+++++++++++++++++++++++++++++++++++++++++++++++++++

In :doc:`new` we describe new protocols that aim to resolve these issues,
by integrating key verification into existing messaging use cases:

- the :ref:`Setup Contact protocol <setup-contact>` allows a user, say Alice,
  to establish a verified contact with another user, say Bob.
  At the end of this protocol,
  Alice and Bob know each other's contact information and
  have verified each other's keys.
  To do so,
  Alice sends bootstrap data using the trusted out-of-band channel to Bob (for
  example, by showing QR code).
  The bootstrap data
  transfers not only the key fingerprint,
  but also contact information (e.g., email address).
  After receiving the out-of-band bootstrap data, Alice's and Bob's clients
  communicate via the regular channel to 1) exchange Bob's key and contact
  information and 2) to verify each other's keys.
  Note that this protocol only uses one out-of-band message requiring
  involvement of the user. All other messages are transparent.

- the :ref:`Verified Group protocol <verified-group>` enables a user to invite
  another user to join a verified group.
  The "joining" peer establishes verified contact with the inviter,
  and the inviter then announces the joiner as a new member. At the end of this
  protocol, the "joining" peer has learned the keys of all members of the group.
  This protocol builds on top of the previous protocol.
  But, this time, the bootstrap data functions as an invite code to the group.

  Any member may invite new members.
  By introducing members in this incremental way,
  a group of size :math:`N` requires only :math:`N-1` verifications overall
  to ensure that a network adversary can not compromise end-to-end encryption
  between group members. If one group member loses her key (e.g. through device loss),
  she must re-join the group via invitation of the remaining members of the verified group.


.. _autocrypt: https://autocrypt.org
