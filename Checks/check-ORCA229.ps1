<#

ORCA-229 - Check allowed domains in MDO Anti-phishing policies 

#>

using module "..\ORCA.psm1"

class ORCA229 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA229()
    {
        $this.Control=229
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Anti-phishing trusted domains"
        $this.PassText="No trusted domains in Anti-phishing policy"
        $this.FailRecommendation="Remove allow listing on domains in Anti-phishing policy"
        $this.Importance="Adding domains as trusted in Anti-phishing policy will result in the action for protected domains, protected users or mailbox intelligence protection will be not applied to messages coming from these sender domains. If a trusted domain needs to be added based on organizational requirements it should be reviewed regularly and updated as needed. We also do not recommend adding domains from shared services."
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
            $ExcludedDomains = $($Policy.ExcludedDomains)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name
            
            <#
            
            Important! Do not apply read only here on preset policies. This can be adjusted.
            
            #>

            If(($ExcludedDomains).Count -gt 0)
            {
                ForEach($Domain in $ExcludedDomains) 
                {
                    # Check objects
                    $ConfigObject = [ORCACheckConfig]::new()
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="ExcludedDomains"
                    $ConfigObject.ConfigData=$($Domain)
                    $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
                    $this.AddConfig($ConfigObject)  
                }
            }
            else 
            {
                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object=$policyname
                $ConfigObject.ConfigItem="ExcludedDomains"
                $ConfigObject.ConfigData="No domain detected"
                $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                $this.AddConfig($ConfigObject)  
            }
        }      

    }

}