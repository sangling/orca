<#

ORCA-228 - Check MDO Anti-Phishing trusted senders  

#>

using module "..\ORCA.psm1"

class ORCA228 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA228()
    {
        $this.Control=228
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Anti-phishing trusted senders"
        $this.PassText="No trusted senders in Anti-phishing policy"
        $this.FailRecommendation="Remove allow listing on senders in Anti-phishing policy"
        $this.Importance="Adding senders as trusted in Anti-phishing policy will result in the action for protected domains, Protected users or mailbox intelligence protection will be not applied to messages coming from these senders. If a trusted sender needs to be added based on organizational requirements it should be reviewed regularly and updated as needed."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.Links= @{
            "Security & Compliance Center - Anti-phishing"="https://aka.ms/orca-atpp-action-antiphishing"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {


        ForEach($Policy in ($Config["AntiPhishPolicy"] ))
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            $ExcludedSenders = $($Policy.ExcludedSenders)

            #  Determine if tips for user impersonation is on

            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object=$Config["PolicyStates"][$Policy.Guid.ToString()].Name
            $ConfigObject.ConfigItem="ExcludedSenders"
            $ConfigObject.ConfigDisabled = $IsPolicyDisabled
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            <#
            
            Important! This setting can be changed on pre-set policies and is not read only. Do not apply read only tag to preset policies.
            
            #>

            If(($ExcludedSenders).count -eq 0)
            {
                $ConfigObject.ConfigData="No Sender Detected"    
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")       
            }
            Else 
            {
                $ConfigObject.ConfigData=$ExcludedSenders
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")                       
            }

            $this.AddConfig($ConfigObject)

        }    

    }

}