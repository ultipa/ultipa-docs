# Settings

Ultipa Manager offers the following settings:

- <a href="#Account-Settings">Account Settings</a>
- <a href="#Connection-Settings">Connection Settings</a>
- <a href="#Admin-Settings">Admin Settings</a>

## Account Settings

You can access **Account Settings** from both the **Instances** page and within an active connection. It includes the following sections:

<table>
  <thead>
    <tr>
      <th style="width:15%;">Section</th>
      <th style="width:15%;">Option</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Profile</td>
      <td></td>
      <td>Displays the Manager account username, authentication model (System or LDAP), and provides the option to reset the password.</td>
    </tr>
    <tr>
      <td rowspan="4">Appearance</td>
      <td>Theme</td>
      <td>Switches the Manager UI theme between Dark and Light modes.</td>
    </tr>
    <tr>
      <td>Language</td>
      <td>Sets the Manager UI language as English, French, or Chinese.</td>
    </tr>
    <tr>
      <td>Time Format</td>
      <td>Selects the format used to display all time values, including <code>timestamp</code> and <code>datetime</code> properties, as well as other time-related elements in the UI.</td>
    </tr>
    <tr>
      <td>Time Zone</td>
      <td>Selects the timezone to which timestamps will be converted. By default, the browser's timezone is used.</td>
    </tr>
    <tr>
      <td>Security</td>
      <td>MFA</td>
      <td>Enables or disables multi-factor authentication (MFA) when logging in to Manager. MFA cannot be disabled if the Manager admin has enabled the <b>Force Enable MFA</b> setting.</td>
    </tr>
    <tr>
      <td>System</td>
      <td>Version</td>
      <td>Displays the version of Ultipa Manager.</td>
    </tr>
  </tbody>
</table>

## Connection Settings

You can access **Connection Settings** within an active connection. It includes the following sections:

| <div table-width="15">Section</div> | Description |
| -- | -- |
| Connection | Shows connection details, including the connection name, host addresses, database username, and password. |
| Tokens | Manages connection tokens used by shared widgets to access the database securely. |
| License | Displays the expiration date of the current database license. |

## Admin Settings

Manager users who are assigned the Admin role can access **Admin Settings** from the Instances page. It includes the following sections:

<table>
  <thead>
    <tr>
      <th style="width:15%;">Section</th>
      <th style="width:15%;">Option</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>User</td>
      <td></td>
      <td>Manages all users in Manager, including their profiles, account status, and connections.</td>
    </tr>
    <tr>
      <td>Connections</td>
      <td></td>
      <td>Manages all connections that have been added in Manager.</td>
    </tr>
    <tr>
      <td rowspan="3">Settings > Appearance</td>
      <td>Watermark</td>
      <td>Sets the text to be used as a watermark, tiled across the Manager interface.</td>
    </tr>
    <tr>
      <td>Welcome Message</td>
      <td>Sets the message to display as the browser tab title for Manager, as well as the message shown on the connection homepage.</td>
    </tr>
    <tr>
      <td>Favicon Link</td>
      <td>Sets the link of the favicon for the Manager pages.</td>
    </tr>
    <tr>
      <td rowspan="3">Settigs > Security</td>
      <td>Enable LDAP</td>
      <td>Enables or disables the LDAP authentication model. If enabled, you must configure the LDAP settings. <a target="_blank" href="/docs/manager-user-guide/users-roles-and-authentication#Login-Authentication">Learn more</a></td>
    </tr>
    <tr>
      <td>Password Strength</td>
      <td>Enables or disables the password strength requirement. If enabled, select the desired strength level from the following options:<ul><li><b>Low:</b> Minimum 6 characters.</li><li><b>Good:</b> Minimum 6 characters, including letters, numbers, and special characters.</li><li><b>Strong:</b> Minimum 8 characters, including uppercase and lowercase letters, numbers, and special characters.</li></ul>The designated password rule applies to all users managed by Ultipa Manager. LDAP-authenticated accounts are not subject to these requirements.</td>
    </tr>
    <tr>
      <td>Force Enable MFA</td>
      <td>Determines whether to enforce multi-factor authentication (MFA) for all users. If enabled, users cannot disable MFA in their <b>Account Settings</b>.</td>
    </tr>
    <tr>
      <td>Settings > System</td>
      <td></td>
      <td>Displays the version of Ultipa Manager.</td>
    </tr>
  </tbody>
</table>
