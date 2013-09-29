Redmine Mail Dispatch Ext plugin
================================

This project is a plugin for redmine.

A base concept of this project is to extend class mailhandler in redmine.

The project got a big hint from the following URL. I mark the appreciation here.
http://d.hatena.ne.jp/coolstyle/20110708/1310100053

Behavior of the this program are as follows:

1. When an issue by a receiving e-mail is register, to recored a messege-id of this e-mail.
2. When the message-id was already recorded in the 'refference' or 'in-reply-to' of new reciving e-mail is included, to register as a reply of the issue.


