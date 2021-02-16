<!doctype>
<html>
	<head>
		<title>Default page for xSITE_NAME</title>
	</head>
	<body>
		<h1>Default page for xSITE_NAME</h1>
		<p>
			This page proves your new site works. You should copy
			any old pages and scripts from a previous site over
			so you can see if it works under the new PHP, and
			make adaptations if required.
		</p>
		<p>
			The options used to generate this page and config
			files for Apache/FastCGI:
		</p>
		<dl>
			<dt>PHP configuration directory</dt>
			<dd><code>xPHPDIR</code></dd>
			<dt>Apache directory (htdocs, logs, conf)</dt>
			<dd><code>xWWWDIR</code></dd>
			<dt>Default port</dt>
			<dd>xPORT</dd>
		</dl>
		<p>
			This page was generated by <code>siteadd</code> from
			<a href="https://www.seidengroup.com/">Seiden Group</a>.
		</p>
		<p>
			When you no longer need this page, please delete it.
		</p>
		<h2>PHP info</h2>
		<?php
		phpinfo();
		?>
	</body>
</html>