import gulp from "gulp";
import path from "path";
import plumber from "gulp-plumber";
import htmlmin from "gulp-htmlmin";
import cleanCSS from "gulp-clean-css";
import uglify from "gulp-uglify";

const paths = {
  root: "./_site",
  html: "./_site/**/*.html",
  css: "./_site/**/*.css",
  js: "./_site/**/*.js",
};

function logCompletion(taskName) {
  console.log(`Task ${taskName} completed successfully.`);
}

gulp.task("minify-html", () => {
  return gulp
    .src(paths.html)
    .pipe(plumber({ errorHandler: (err) => console.error(err) }))
    .pipe(htmlmin({ collapseWhitespace: true }))
    .pipe(gulp.dest(paths.root))
    .on("end", () => logCompletion("minify-html"));
});

gulp.task("minify-css", () => {
  return gulp
    .src(paths.css)
    .pipe(plumber({ errorHandler: (err) => console.error(err) }))
    .pipe(cleanCSS({ compatibility: "ie8" }))
    .pipe(
      gulp.dest((file) => {
        const relativePath = path.relative(path.resolve(paths.root), file.base);
        return path.join(paths.root, relativePath);
      })
    )
    .on("end", () => logCompletion("minify-css"));
});

gulp.task("minify-js", () => {
  return gulp
    .src(paths.js)
    .pipe(plumber({ errorHandler: (err) => console.error(err) }))
    .pipe(uglify())
    .pipe(
      gulp.dest((file) => {
        const relativePath = path.relative(path.resolve(paths.root), file.base);
        return path.join(paths.root, relativePath);
      })
    )
    .on("end", () => logCompletion("minify-js"));
});

gulp.task("default", gulp.series("minify-html", "minify-css", "minify-js"));
