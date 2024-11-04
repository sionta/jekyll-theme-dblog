import gulp from "gulp";
import path from "path";
import plumber from "gulp-plumber";
import htmlmin from "gulp-htmlmin";
import cleanCSS from "gulp-clean-css";
import uglify from "gulp-uglify";

const paths = {
  html: "./_site/**/*.html",
  css: "./_site/**/*.css",
  js: "./_site/**/*.js",
};

gulp.task("minify-html", () => {
  return gulp
    .src(paths.html)
    .pipe(plumber())
    .pipe(htmlmin({ collapseWhitespace: true }))
    .pipe(gulp.dest("./_site"));
});

gulp.task("minify-css", () => {
  return gulp
    .src(paths.css)
    .pipe(plumber())
    .pipe(cleanCSS({ compatibility: "ie8" }))
    .pipe(
      gulp.dest((file) => {
        const relativePath = path.relative(path.resolve("./_site"), file.base);
        return path.join("./_site", relativePath);
      })
    )
    .on("end", () => {
      console.log(`Minified CSS processed.`);
    });
});

gulp.task("minify-js", () => {
  return gulp
    .src(paths.js)
    .pipe(plumber())
    .pipe(uglify())
    .pipe(
      gulp.dest((file) => {
        const relativePath = path.relative(path.resolve("./_site"), file.base);
        return path.join("./_site", relativePath);
      })
    )
    .on("end", () => {
      console.log(`Minified JS processed.`);
    });
});

// Default task without image optimization
gulp.task("default", gulp.series("minify-html", "minify-css", "minify-js"));
