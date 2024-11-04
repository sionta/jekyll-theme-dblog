# Jekyll Theme dBlog

Welcome to **Jekyll Theme dBlog**! This theme is designed to provide a streamlined experience for creating and managing your blog. In this directory, you will find all the necessary files to package your theme as a gem, allowing for easy installation and use in Jekyll sites.

## Directory Structure

- **_layouts/**: Place your layout files here.
- **_includes/**: Include reusable components in this directory.
- **_sass/**: Add your SASS files to this folder for styling.
- **assets/**: Store any other assets such as images, fonts, or JavaScript files.

To start experimenting with the theme, add some sample content and run:

```bash
bundle exec jekyll serve
```

This directory is configured like a standard Jekyll site, enabling you to preview your changes in real-time.

## Installation

To install the **Jekyll Theme dBlog**, follow these steps:

1. Add the following line to your Jekyll site's `Gemfile`:

   ```ruby
   gem "jekyll-theme-dblog"
   ```

2. Then, include this line in your Jekyll site's `_config.yml`:

   ```yaml
   theme: jekyll-theme-dblog
   ```

3. Execute the command below to install the theme:

   ```bash
   bundle
   ```

   Alternatively, you can install the theme manually by running:

   ```bash
   gem install jekyll-theme-dblog
   ```

## Usage

### Building the Site with Minification

The theme supports site building with minification for HTML, CSS, and JavaScript files. Please note that minification is only applied when executing the `build` command, and it will not occur during the `serve` command.

To build your site with minification, follow these steps:

1. Install the necessary dependencies:

   ```bash
   npm install
   ```

2. Build the site with minification:

   ```bash
   npm run build
   ```

### Available Features

* **Layouts**: Describe your layouts here and provide instructions on how to use them.
* **Includes**: Document the available includes and their purposes.
* **SASS**: Explain how to use your SASS files for styling.
* **Assets**: Detail any additional assets and how they are integrated into the theme.

## Contributing

We welcome bug reports and pull requests on GitHub at [https://github.com/sionta/jekyll-theme-dblog](https://github.com/sionta/jekyll-theme-dblog). This project aims to foster a collaborative and inclusive environment, and all contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## Development

To set up your development environment for this theme, execute the following command:

```bash
bundle install
```

Your theme is set up just like any standard Jekyll site! To test the theme, run:

```bash
bundle exec jekyll serve
```

Open your browser at `http://localhost:4000` to view your site. You can add pages, documents, data, and more to see how your theme handles various content types. As you modify the theme and content, the site will regenerate, and changes will be reflected in the browser after a refresh.

When ready for release, only the files in `_layouts`, `_includes`, `_sass`, and `assets` that are tracked with Git will be included in the gem. To add custom directories to your theme gem, please edit the regular expression in `jekyll-theme-dblog.gemspec` accordingly.

## License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
