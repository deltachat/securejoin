
# I. Happy path and Resetup Scenarios with green-checkmarked chatting

**Printed in bold** indicates a UX or implementation **difference or gap**
to the current Android and core main (2023-11-09, 9775e6c69 resp. 1856c622a).

## Device Resetup 1: with pre-existing 1:1 chat

1. Alice adds Bob to a guranteed e2ee CHATGROUP where Carol is already a member
   
   1.1 **Bob sees the "e2ee-activation" system message in the CHATGROUP**

2. Bob goes to the CHATGROUP contact list 
   and selects the green-checkmarked Carol 
   and looks at her profile.

3. **Carol's contact profile has a green checkmark in the title bar
   ([#4950](https://github.com/deltachat/deltachat-core-rust/issues/4950)).**
   Bob selects "send message" and goes to his 1:1 green-checkmarked 
   BOB/CAROL chat which shows the "e2ee-activation" system message
   before he starts writing.

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

8. After re-scanning Carol into the group, she will be able to 
   decrypt all messages and as soon as she sends a message to the group
   everyone will recognize that Bob's verified key introduction
   was valid and enable green checkmark for Carol. 


## Device Resetup 2: without existing 1:1 chats

Resetup 2 scenario produces the same series of steps as the previous Resetup-Scenario 1, 
except step 3 didn't happen because Carol and Bob never exchanged 1:1 messages.

**Note that Bob in step 7 will still see "e2ee-activiation" and "e2ee-broken" messages
even if the chat only appeared for Bob due to Carol's "I can't read" message. 
The main user-visible difference between the scenarios is that 
in scenario 2 there are no messages between the "e2ee-activation" and "e2ee-broken" messages,
while scenario 1 has chat messages between them (due to Step 3) (#TODO).**

# II. Implementation considerations 

**Printed in bold** indicates a UX or implementation **difference or gap**
to the current Android 1.41.5 APK and core 1.129.1.

## Eventual group key consistency by providing "actionable" items to users

When green-checkmarked Alice adds Bob and sends a member-added message to the group, 

- then Bob will **store the gossip keys for group members as a secondary key 
  unless he knows them already as a primary key. As soon as he sees direct messages
  from a secondary-verified contact the the secondary key gets promoted to become
  the primary** (see https://github.com/deltachat/deltachat-core-rust/pull/4898).

- all other members receiving "member-bob-added" 
  will also add Bob's verified key into their secondary key slot (also #4898)
  and promote it to primary when seeing a direct message from Bob. 
 
Note that 1:1 chats might be "e2ee-broken" between Bob and  group members
if either side had an old primary verified key and a newer autocrypt-direct key. 
The secondary-gossip key approach does not solve that but again, 
as soon as the 1:1 chat partners see direct messages from each other 
the "e2e-guaranteed" message will show. 

- IF Bob has no existing 1:1 chat with a member of a green group where he was
  joined: 
  
  **create a *hidden* 1:1 chat for Bob with the member 
  and post a "e2ee-activation" message. (#TODO) **
  This does not make the chat visible in the chatlist at all
  but when the chat later breaks, there will be day markers
  providing additional clues when guaranteed e2ee was introduced 
  and when it degraded, now showing the e2ee-broken message. 

## A note on migrations from 1.40 to 1.42

While it's probably OK to not do anything wrt green chats during upgrade, 
**it would also make sense to post "e2ee-activated" messages at least
for all chats with contacts (that saw messages in the last 30-60 days?) (#TODO)**.
It's a 1.42 feature after all and a one-time (pleasant for many) surprise 
and likely not too many people have "shitloads" of verifications, anyway. 

