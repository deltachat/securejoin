
# I. Happy path and Resetup Scenarios with green-checkmarked chatting

**Printed in bold** indicates a UX or implementation **difference or gap**
to the current Android 1.41.5 APK and core 1.129.1.

## Device Resetup 1: with pre-existing 1:1 chat

1. Alice adds Bob to a guranteed e2ee CHATGROUP 

2. Bob goes to the CHATGROUP contact list 
   and selects the green-checkmarked Carol 
   and looks at her profile.

3. **Carol's contact profile has a green checkmark in the title bar.
   Bob selects "send message" and goes to his 1:1 green-checkmarked 
   BOB/CAROL chat which shows the "e2ee-activation" system message
   before he starts writing.** 

--- time passes and then some more ---

4. Carol re-setups her device, without using backup/md-setup.

5. CHATGROUP: Bob writes a message into the group

6. CAROL/BOB: Carol sees an "undecryptable" message from Bob.
   She writes back "I can't read your message" to Bob.

7. BOB/CAROL chat: is suspended/blocked and Bob sees a "broken-e2ee" message
   and Carols' "i can't read ..." message.
   Bob can discover through "learn more" 
   and the visual "broken-e2ee" message
   that he needs to re-invite Carol to the group,
   or at least perform a 1:1 QR scan to fix their 1:1 chat.


## Device Resetup 2: without existing 1:1 chats

Resetup 2 scenario produces the same series of steps as the previous Resetup-Scenario 1, 
except step 3 didn't happen because Carol and Bob never exchanged 1:1 messages. 

Note that Bob in step 7 will still see "e2ee-activiation" and "e2ee-broken" messages
even if the chat only "popped" up for Bob due to Carol's "I can't read" message. 

The main user-visible difference between the scenarios is that 
in scenario 2 there are no messages between the "e2ee-activation" and "e2ee-broken" messages,
while scenario 1 has chat messages between these two system messages (see Step 3).

# II. Implementation considerations 

## Eventual group key consistency by providing "actionable" items to users

When green-checkmarked Alice adds Bob and sends a member-added message to the group, 

- then Bob will **Unconditionally overwrite green keys and Autocrypt public_keys 
  for all contacts introduced by Alice, 
  so that Alice and Bob are fully synchronized on group member keys.** 
  This does not imply that Alice/Bob's now joint view on keys is correct, however.  
  Bob might have had a "better" or "more recent" key from a contact 
  than what Alice had provided when adding Bob. This will potentially degrade Bob's 
  chats with individual group members but this comes with a visible warning 
  and the advise to Bob to let the degraded contact re-scan at best the group invite code,
  **so that Bob in turn fixes keys for the degraded contact for Alice and all group members.**
  Note that when members in a green group have divergent views on (green) keys,
  two people must eventually be bothered to make it consistent.
  This "care" can not be avoided as it is the basic building block 
  for "guaranteed e2e groups safe against active attacks".
  (With all other messengers each group member must reverify with the degraded contact.)

- all other members receiving "member-bob-added" 
  will (re)set Bob's green **and Autocrypt key**. 
  **All group members, including Alice, thus fully agree on the keys for Bob.**
 
**To summarize, after member-added all group members have the same keys for Bob,
and Bob will have the same keys as Alice for all other members.**

When Alice adds Bob, then Bob's device will also post, as needed, 
"e2ee-activation/broken" messages for each group member C: 

- IF Bob has an existing 1:1 chat with a member: 

  - IF the chat was not green, post a "e2ee-activated" message into it. 
    Moves it to the top of the chatlist which is fine. 

  - ELSE the chat was green and the members green key changed: 
    **e2ee-broken and "e2ee-activiation" messages (maybe later: a new message)**
    Moves it to the top of the chatlist which is fine. 

  - ELSE the chat was green and the members green key did not change: do nothing. 

- IF Bob has no existing 1:1 chat with a member: 
  
  **create a *hidden* 1:1 chat for Bob with the member 
  and post a "e2ee-activation" message.**
  This does not make the chat visible in the chatlist at all
  but when the chat later breaks, there will be day markers
  providing additional clues when guaranteed e2ee was introduced 
  and when it degraded, now showing the e2ee-broken message. 


## missed member-added messages, group membership consistency

If Bob misses a member-added message, he will subsequently add members
if they are in the "To" header but not members. He should probably
also treat the gossiped green keys as 
if he had received "member-added" messages with them. 

Note that the "strong" influence of member-added on consistent keys of group members,
does not imply that member-added messages determine group membership consistency
questions in a similar way. 


## Changed "can not be decrypted" message that Carol sees

The current message reads:

```
... – [This message cannot be decrypted. 
• It might already help to simply reply to this message 
and ask the sender to send the message again. 
• In case you re-installed Delta Chat or another e-mail program 
on this or another device you may want to send an Autocrypt Setup Message from there.] -
```

It should probably read something like: 

**... – [This message cannot be decrypted. • It might already help to simply reply and ask 
your contact to send the message again. • If you just re-installed Delta Chat 
but are also running it on another device, 
then it is best to re-setup Delta Chat now and choose "add as second device". ] -**
