/********************************
 * Developed By: Joshua Ramczyk 
 * Date Developed: 11/23/2021
 ********************************/

global class VMMR_Email implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String matched;        
	String now = string.valueOfGmt(System.Now());
        VMM_Report__c vmmr;

        Pattern pattern = Pattern.compile('(VMMR-[0-9]{9})');
        Matcher match = pattern.matcher(email.subject);
        System.debug(email.subject);
        if(match.find()){            
			matched = match.group(1);
       		System.debug(matched);
        }
        
        LIST <VMM_Report__c> vmmr_list = [SELECT Name FROM VMM_Report__c WHERE Name = :matched];        

        try{
            if(vmmr_list.isEmpty()){
                vmmr = new VMM_Report__c();                              
				vmmr.Email__c = 'Subject: ' + email.subject + 
                    				 '\n From: ' + email.fromAddress + 
                    				 '\n CCd: ' + email.ccAddresses +                     				 
                    				 '\n Email Body: ' + email.plainTextBody;
                insert vmmr;
            }else{
                vmmr = [SELECT Name, Email__c FROM VMM_Report__c WHERE Name = :matched];
                string email_body = vmmr.Email__c;
                vmmr.Email__c = 'Subject: ' + email.subject + 
                    				 '\n From: ' + email.fromAddress + 
                    				 '\n CCd: ' + email.ccAddresses +                     				 
                    				 '\n Email Body: ' + email.plainTextBody +
                    				 '\n\n\n' + email_body;
                upsert vmmr;
            }
                
            List<Attachment> attachments = new List<Attachment>();
            if(email.textAttachments != null){
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                Attachment attachment = new Attachment();
                attachment.Name = now + ' ' + tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = vmmr.Id;
                attachments.add(attachment);
                }
            }
            if(email.binaryAttachments != null){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                Attachment attachment = new Attachment();        
                attachment.Name = now + ' ' + bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = vmmr.Id;
                attachments.add(attachment);
                }
            }       
            if(attachments.size() > 0){
                upsert attachments;
            } 
            
            result.success = true;
        }catch(Exception e){
            result.success = false;
            result.message = e.getMessage() + e.getStackTraceString();
        }
        
        return result;                                                      
    }
}
