Commandbox Licenses

The Licenses module is designed to display or export the license information for a ColdBox site. By default the information is based on the current working directory and is displayed on the screen. 

`box licenseInfo licenses`

Options:
@folder - defaults to the current working directory but can be any absolute file path

@ExportTo - defaults to screen but other options include "csv"
 Screen - this will output in the CommandBox terminal a "tree" formatted list of dependencies and what license (MIT, Apache2 etc) that the package is bound by. Useful for code reviews.

|-ColdBox Security Apache2

&nbsp;&nbsp;&nbsp;&nbsp;|-cbauth MIT

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-CBStorages Apache2

&nbsp;&nbsp;&nbsp;&nbsp;|-ColdBox Cross Site Request Forgery (CSRF) Apache2

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-CBStorages Apache2

&nbsp;&nbsp;&nbsp;&nbsp;|-JWT CFML MIT

csv - will create a csv file (named with the filename argument, defaults to licenseData) with the columns:
 - name
 - version
 - license
 - indents (to help recreate the tree structure later if desired)