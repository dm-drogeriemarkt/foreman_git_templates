# ForemanGitTemplates

[<img src="https://raw.githubusercontent.com/dm-drogeriemarkt/.github/refs/heads/main/assets/dmtech-open-source-badge.svg">](https://www.dmtech.de/)

This is a plugin for Foreman that adds support for using templates from Git repositories.

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | -------------- |
| >= 1.20         | ~> 1.0         |
| >= 3.9          | ~> 2.0         |

## Installation

See [Plugins install instructions](https://theforeman.org/plugins/) for how to install Foreman plugins.

## Usage

Repositories are fetched as tarball files and must have a specific file structure. The root directory should be named `templates`. Inside the root directory there should be directories for template kinds and for snippets. Only one template for template kind is supported however multiple snippets are supported. Template file should be named `template.erb`. You can also define a default local boot template in the file named `default_local_boot.erb`. Snippet filenames will be downcased and spaces will be replaced by underscores.

```
.
└── templates
    ├── PXELinux
    │   ├── template.erb
    │   └── default_local_boot.erb
    ├── provision
    │   └── template.erb
    └── snippets
        ├── snippet_1.erb
        └── snippet_2.erb
```

In order to use templates from the repository you have to set `template_url` host parameter (specify the HTTP authentication credentials if necessary). To set host parameters navigate to the edit host page and open "Parameters" tab.

![Host Parameters](./doc/images/host_parameters.png)

From now the template content for this host will be fetched from the repository. To test this open `/unattended/provision?spoof=<host_ip>`. The template stored in the `provision` directory should be rendered.

### Troubleshooting

- `There was an error rendering the provision template: Cannot fetch repository from <template_url>. Response code: 404`
  - check if the URL is correct
- `There was an error rendering the provision template: Cannot read <template> from repository`
  - check if there is requested template in the repository

### Gitlab Repository Integration

If you want to use a private repository hosted on a Gitlab instance to store your Foreman templates, you can use [Gitlab's repositories API](https://docs.gitlab.com/ee/api/repositories.html#get-file-archive) to construct the `template_url` parameter in Foreman. Create a dedicated Foreman user in Gitlab and set up a Personal Access Token that you can use in the `template_url`.

```
https://gitlab.example.com/api/v4/projects/${GITLAB_PROJECT_ID}/repository/archive.tar.gz?sha=${GITLAB_BRANCH_NAME}&private_token=${PERSONAL_ACCESS_TOKEN}
```

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2018 dmTECH GmbH, [dmtech.de](https://www.dmtech.de/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
