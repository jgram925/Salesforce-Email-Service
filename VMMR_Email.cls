global class VMMR_Email implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        VMM_Report__c vmmr;
        LIST <VMM_Report__c> vmmr_list = [SELECT Name FROM VMM_Report__c WHERE Name = :email.subject];        

        try{
            if(vmmr_list.isEmpty()){
                vmmr = new VMM_Report__c();
                vmmr.Name = email.subject;
                vmmr.From_Email__c = email.fromAddress;
                vmmr.Email_Body__c = email.plainTextBody;
                insert vmmr;                
            }else{
                vmmr = [SELECT Name FROM VMM_Report__c WHERE Name = :email.subject];
            }
                
            List<Attachment> attachments = new List<Attachment>();
            if(email.textAttachments != null){
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = vmmr.Id;
                attachments.add(attachment);
                }
            }
            if(email.binaryAttachments != null){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                Attachment attachment = new Attachment();        
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = vmmr.Id;
                attachments.add(attachment);
                }
            }       
            if(attachments.size() > 0){
                insert attachments;
            }        
            result.success = true;
        }catch(Exception e){
            result.success = false;
            result.message = e.getMessage() + e.getStackTraceString();
        }
        
        return result;                                                      
    }
}
