using module "..\ORCA.psm1"

class ORCA222 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA222()
    {
        $this.Control=222
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Domain Impersonation Action"
        $this.PassText="Domain Impersonation action is set to move to Quarantine"
        $this.FailRecommendation="Configure domain impersonation action to Quarantine"
        $this.Importance="Domain Impersonation can detect impersonation attempts against your domains or domains that look very similiar to your domains. Move messages that are caught using this impersonation protection to Quarantine."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Medium
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

        <#
        
        This check does not need a default fail if no policies exist
        
        #>

        ForEach($Policy in ($Config["AntiPhishPolicy"] | Where-Object {$_.Enabled -eq $True}))
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            $EnableTargetedDomainsProtection = $($Policy.EnableTargetedDomainsProtection)
            $EnableOrganizationDomainsProtection = $($Policy.EnableOrganizationDomainsProtection)
            $TargetedDomainProtectionAction = $($Policy.TargetedDomainProtectionAction)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            <#
            
            EnableTargetedDomainsProtection / EnableOrgainizationDomainsProtection
            
            #>

            If($EnableTargetedDomainsProtection -eq $False -and $EnableOrganizationDomainsProtection -eq $False)
            {
                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()

                $ConfigObject.Object=$policyname
                $ConfigObject.ConfigItem="EnableTargetedDomainsProtection"
                $ConfigObject.ConfigData=$EnableTargetedDomainsProtection
                $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                $ConfigObject.ConfigReadonly = $Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                $this.AddConfig($ConfigObject)
                
                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()

                $ConfigObject.Object=$policyname
                $ConfigObject.ConfigItem="EnableOrganizationDomainsProtection"
                $ConfigObject.ConfigData=$EnableOrganizationDomainsProtection
                $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                $ConfigObject.ConfigReadonly = $Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                $this.AddConfig($ConfigObject)       
            }
            
            If($EnableTargetedDomainsProtection -eq $True)
            {

                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object=$policyname
                $ConfigObject.ConfigItem="EnableTargetedDomainsProtection"
                $ConfigObject.ConfigData=$EnableTargetedDomainsProtection
                $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                $ConfigObject.ConfigReadonly = $Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                $this.AddConfig($ConfigObject)

            }
    
            If($EnableOrganizationDomainsProtection -eq $True)
            {

                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object=$policyname
                $ConfigObject.ConfigItem="EnableOrganizationDomainsProtection"
                $ConfigObject.ConfigData=$EnableOrganizationDomainsProtection
                $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                $ConfigObject.ConfigReadonly = $Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                $this.AddConfig($ConfigObject)
         
            }

            
            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="TargetedDomainProtectionAction"
            $ConfigObject.ConfigData=$TargetedDomainProtectionAction
            $ConfigObject.ConfigDisabled = $IsPolicyDisabled
            $ConfigObject.ConfigReadonly = $Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            If($TargetedDomainProtectionAction -eq "Quarantine")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")          
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail") 
            }

            If($TargetedDomainProtectionAction -eq "Delete" -or $TargetedDomainProtectionAction -eq "Redirect")
            {
                # For either Delete or Quarantine we should raise an informational
                $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                $ConfigObject.InfoText = "The $($TargetedDomainProtectionAction) option may impact the users ability to release emails and may impact user experience."
            }

            $this.AddConfig($ConfigObject)
    
        } 

    }

}