
# I. Happy path and Resetup Scenarios with green-checkmarked chatting

## Device Resetup 1: with pre-existing 1:1 chat

1. Alice adds Bob to a guranteed e2ee CHATGROUP 

2. Bob goes to the CHATGROUP contact list 
   and selects the green-checkmarked Carol 
   and looks at her profile.

3. **Carol's contact profile has a green checkmark in the title bar.
   Bob selects "send message" and goes to his 1:1 green-checkmarked 
   BOB/CAROL chat which has the "e2ee-activation" system message
   before he starts writing.**

--- time passes ---

4. Carol re-setups her device, without using backup/md-setup

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

## Eventual key consistency in groups

When green-checkmarked Alice adds Bob and sends a member-added message to the group, 

- then Bob will **Unconditionally overwrite green keys and Autocrypt public_keys 
for all contacts introduced from Alice**. 

- all other members receiving "member-bob-added" 
  will (re)set Bob's green **and Autocrypt key** 

Bob's device will also post, as needed, "e2ee-activation/broken" messages for chat C: 

- IF Bob has an existing 1:1 chat with C: 

  - IF the chat was not green, post a "e2ee-activated" message into it. 

  - ELSE the chat was green and C's green key changed: 
    **e2ee-broken and "e2ee-activiation" messages (maybe later: a new message)**

  - ELSE the chat was green and C's green key did not change: do nothing. 

- IF Bob has no existing 1:1 chat with C: 
  
     - create a *hidden* 1:1 chat for Bob with C 
     - post a "e2ee-activation" message. 


## missed member-added messages 

If Bob misses a member-added message, he will subsequently add members
if they are in the "To" header but not members. He should probably
also treat the gossiped green keys as 
if he had received "member-added" messages with them. 

## Changed "can not be decrypted" message that Carol sees

- strike Autocrypt-setup
- streamline it to reflect FAQ wordings (maybe with LearnMore button) 

