# UCDCreateSharedMailbox
Shared mailbox automation script for use by UCD Service Desk

This script is provided as-is with no warranty to suitability or usability.

Purpose:
  To standardize and speed up the creation of new shared mailboxes for UCD Service Desk employees. This script is purely console-based and does not have a GUI.
  
 Requirements:
  Powershell
  Exchange Online Management Powershell module: https://www.powershellgallery.com/packages/ExchangeOnlineManagement You will be prompted to install the module if it is not available in your list of modules the first time you run the script.
  Relevant Exchange Online permissions to create shared mailboxes and mail-enabled security groups.
  
 Usage:
  Run the script, either directly or by opening it within a Powershell instance and then running it that way.
  If the EXO module is not installed, you will be asked to install it.
  You will be prompted for your EA email address.
  Provide the intended mailbox name.
  Provide a comma-separated list of the owners of the mailbox.
  Provide a comma-separated list of the members of the mailbox.
  
  The script will then perform the necessary steps to create the mail-enabled security group to manage the mailbox, as well as add owners/members, create the shared mailbox and assign the SG read/send as permissions to the new shared mailbox.
  
Potential issues:
  If a shared mailbox with the same name already exists then that portion of the process will error out, though if there is no related SG then it will be created.
  
 Todos:
  Enhance error handling.
  Work in CSV parsing for large groups of users.
  Look into creating a more friendly UI.
