<#

Checks MDO Anti-phishing policy Advanced phishing thresholds 

#>

using module "..\ORCA.psm1"

class ORCA220 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA220()
    {
        $this.Control=220
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Advanced Phishing Threshold Level"
        $this.PassText="Advanced Phish filter Threshold level is adequate."
        $this.FailRecommendation="Set Advanced Phish filter Threshold to 2 or 3"
        $this.Importance="The higher the Advanced Phishing Threshold Level, the stricter the mechanisms are that detect phishing attempts against your users, however, too high may be considered too strict."
        $this.ExpandResults=$True
        $this.ItemName="Antiphishing Policy"
        $this.DataType="Advanced Phishing Threshold Level"
        $this.ChiValue=[ORCACHI]::Medium
        $this.ObjectType="Policy"
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


        ForEach($Policy in $Config["AntiPhishPolicy"]) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $PhishThresholdLevel = $($Policy.PhishThresholdLevel)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$policyname
            $ConfigObject.ConfigData=$PhishThresholdLevel
            $ConfigObject.ConfigDisabled = $IsPolicyDisabled
            $ConfigObject.ConfigReadonly = $Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            # Standard

            If($PhishThresholdLevel -eq 2)  
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # Strict

            If($PhishThresholdLevel -eq 3)
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,"Pass")
            } 
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,"Fail")
            }

            $this.AddConfig($ConfigObject)


        }
        
        If($Config["AnyPolicyState"][[PolicyType]::Antiphish] -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="No Enabled Policies"
            $ConfigObject.ConfigData=""
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            $this.AddConfig($ConfigObject)
        }       

    }

}