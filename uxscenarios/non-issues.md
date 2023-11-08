

## shared account usage with prefer-encrypt=no causes drop/re-enable 

If users use both DC and another e-mail client they sometimes
disable "prefer end to end encryption" in the advanced settings
to keep mails more readable among their apps. 
If they also have QR-code scans with contacts
then their 1:1 chat with them will default to guaranteed e2ee. 
But if the other side now sends unencrypted mail (or you do so yourself)
then the 1:1 chat will drop to unencrypted (needs "OK" by user). 
As soon as the other side, or you yourself, use DC again
the chat will auto-upgrade to guaranteed e2ee.  
This pattern can repeat often. 

Status: not an issue for 1.42 releases, and likely not for later ones because:

- these days DC is available on all platforms, setting up second device
  is nice, so no good reason not to use it multi-device.

- if someone uses their webmail (or you yourself do)
  then you will probably use it for some hours
  and during this time in the 1:1 chat things will be unencrypted. 
  As soon as both use DC again, it will turn on encryption. 
  There is not even a need for prefer-encrypt settings for this behaviour. 
