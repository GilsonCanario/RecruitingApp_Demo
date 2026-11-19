/**
 * CommunitiesSelfRegController
 *
 * Handles community self-registration. Configuration values (profile name and
 * account name) are sourced from the SelfReg_Setting__mdt Custom Metadata record
 * named "Default", avoiding hard-coded placeholders and preventing runtime
 * exceptions during portal-user creation.
 */
public without sharing class CommunitiesSelfRegController {

    public String firstName { get; set; }
    public String lastName  { get; set; }
    public String email     { get; set; }
    public String password  { get; set; }
    public String confirmPassword { get; set; }

    public CommunitiesSelfRegController() {}

    @TestVisible
    private static String getSettingProfileName() {
        List<SelfReg_Setting__mdt> settings = [
            SELECT ProfileName__c
            FROM   SelfReg_Setting__mdt
            WHERE  DeveloperName = 'Default'
            WITH   SECURITY_ENFORCED
            LIMIT  1
        ];
        if (settings.isEmpty() || String.isBlank(settings[0].ProfileName__c)) {
            throw new SelfRegException('SelfReg_Setting__mdt.Default.ProfileName__c is not configured.');
        }
        return settings[0].ProfileName__c;
    }

    @TestVisible
    private static String getSettingAccountName() {
        List<SelfReg_Setting__mdt> settings = [
            SELECT AccountName__c
            FROM   SelfReg_Setting__mdt
            WHERE  DeveloperName = 'Default'
            WITH   SECURITY_ENFORCED
            LIMIT  1
        ];
        if (settings.isEmpty() || String.isBlank(settings[0].AccountName__c)) {
            throw new SelfRegException('SelfReg_Setting__mdt.Default.AccountName__c is not configured.');
        }
        return settings[0].AccountName__c;
    }

    @TestVisible
    private static String resolveProfileId(String profileName) {
        List<Profile> profiles = [
            SELECT Id
            FROM   Profile
            WHERE  Name = :profileName
            WITH   SECURITY_ENFORCED
            LIMIT  1
        ];
        if (profiles.isEmpty()) {
            throw new SelfRegException('Profile not found: ' + profileName);
        }
        return profiles[0].Id;
    }

    @TestVisible
    private static String resolveAccountId(String accountName) {
        List<Account> accounts = [
            SELECT Id
            FROM   Account
            WHERE  Name = :accountName
            WITH   SECURITY_ENFORCED
            LIMIT  1
        ];
        if (accounts.isEmpty()) {
            throw new SelfRegException('Account not found: ' + accountName);
        }
        return accounts[0].Id;
    }

    public PageReference registerUser() {
        // Basic input validation
        if (password != confirmPassword) {
            ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.ERROR,
                Label.site.passwords_dont_match
            );
            ApexPages.addMessage(msg);
            return null;
        }

        User u = new User();
        u.Username       = email;
        u.Email          = email;
        u.FirstName      = firstName;
        u.LastName       = lastName;
        u.CommunityNickname = email;

        String profileName  = getSettingProfileName();
        String accountName  = getSettingAccountName();
        String profileId    = resolveProfileId(profileName);
        String accountId    = resolveAccountId(accountName);

        try {
            String userId = Site.createExternalUser(u, accountId, password);
            if (userId != null) {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        } catch (Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String err : errors) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err));
            }
        }

        return null;
    }

    public class SelfRegException extends Exception {}
}
