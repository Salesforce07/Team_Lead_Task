/*
*********************************************************
Apex Class Name    : EmailManager
Created Date       : Sept. 11
@description       : This class is used for Sending mail.
@author            : Shyam Upadhyay
Modification Log:
Ver   Date         Author                               Modification
1.0   11-09-2024   Shyam Upadhyay                     Initial Version
*********************************************************
*/

public with sharing class EmailManager {

    
    /*
*********************************************************
@Method Name    : sendEmail
@author         : Shyam Upadhyay
@description    : method is used to send email.
@param          : String address, String subject, String body
@return         : void
********************************************************
*/
    public static void sendEmail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
