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
we present and discuss SecureJoin protocols as a new, practically usable
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
which was created by researchers of NEXTLEAP,
a 2016-2018 project on privacy and decentralized messaging,
funded through the EU Horizon 2020 programme.


Attack model and terminology
++++++++++++++++++++++++++++

We consider

- *Peer* devices that use network messages for transporting messages
  and for key-exchange in order to establish end-to-end encryption.

- A *network adversary* that can read, modify, and create
  network messages.
  Examples of such an adversary are an ISP, an e-mail provider, an AS,
  or an eavesdropper on a wireless network.
  The goal of the adversary is to i) read the content of messages,
  and to ii) impersonate *peer* devices.

We assume that

- All peers are honest and do not collaborate with the network adversary.

- A Peer (Alice) can send a single QR-code sized *invite code*
  in an *out-of-band channel* to another peer (Bob).
  The attacker can not observe or modify the invite code.

The SecureJoin protocols allow *peer* devices
to establish *guaranteed end-to-end encryption*
that is resistant to machine-in-the-middle attacks by
preventing the adversary from reading messages or impersonating honest peers.

Passive adversaries such as message transport providers can still learn
which peers communicate with each other,
at what time and the approximate size of the messages.

An adversary who can observe Alice's invite code in the out-of-band channel
can perform impersonation attacks.
Additional measures can
relax the security requirements for the out-of-band channel
to also work under a threat of observation.

..
  TODO: Explain 'verified' and 'protected' terminology in the code,
  and 'green checkmark' terminology in thd UI

Disadvantages of other key-verification techniques
++++++++++++++++++++++++++++++++++++++++++++++++++

An important aspect of guaranteed end-to-end (e2e) encryption is the verification of
a peer's key.
In many existing e2e-encrypting messengers like Signal or Element,
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
  Alice sends an *invite code* using the second channel to Bob (for
  example, by showing it as a QR code).
  The invite code
  transfers not only the key fingerprint,
  but also contact information (e.g., email address).
  After receiving the second-channel invite code, Alice's and Bob's clients
  communicate via the regular messaging channel to 1) exchange Bob's key and contact
  information and 2) to verify each other's keys.
  Note that this protocol only uses one out-of-band message requiring
  involvement of the user. All other messages
  are sent in the regular channel potentially controlled by a network adversary.
  Note that this protocol only requires one *invite code* to be transferred un-observed.
  All other messages are exchanged on the regular messaging channel controled by the network adversary.

- the :ref:`Verified Group protocol <verified-group>` enables a user to invite
  another user to join a verified group as a new member.
  This protocol builds on top of the previous protocol.
  The "joining" peer first establishes verified contact with the inviter,
  and the inviter then announces the joiner as a new member. At the end of this
  protocol, the "joining" peer has learned the keys of all members of the group.

  Any group member may invite new members.
  By introducing members in this incremental way,
  a group of size :math:`N` requires only :math:`N-1` verifications overall
  to ensure that a network adversary can not compromise end-to-end encryption
  between group members. If one group member loses her key (e.g. through device loss),
  she must re-join the group via invitation of the remaining members of the verified group.

.. TODO: this subsection is superfluous / redundant and should be merged with what is in new.rst


.. _autocrypt: https://autocrypt.org


Known Limitations and Issues
++++++++++++++++++++++++++++

- The verification of the fingerprint only checks the current keys.
  Since protocols do not store any historical information about keys,
  the verification can not detect if there was a past temporary
  MITM-exchange of keys (say the network adversary
  exchanged keys for a few weeks but changed back to the "correct" keys afterwards).

