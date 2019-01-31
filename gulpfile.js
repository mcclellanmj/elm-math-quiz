var gulp = require('gulp');
var elm  = require('gulp-elm');
var browserSync = require('browser-sync').create();

gulp.task('static', function() {
  return gulp.src('src/static/**', { base: 'src/static' })
    .pipe(gulp.dest('dist/'));
});

function buildElm(debug) {
  return gulp.src('src/elm/Main.elm')
    .pipe(elm.bundle('elm.js', { debug: debug }))
    .pipe(gulp.dest('dist/'));
}

gulp.task('elmDebug', function(){
  return buildElm(true);
});

gulp.task('elmBuild', function() {
  return buildElm(false);
});

gulp.task('build', gulp.series('static', 'elmBuild'));

gulp.task('serve', gulp.series('static', 'elmDebug', function() {
  browserSync.init({
    server: 'dist/',
    cors: true,
    index: 'index.html'
  });

  gulp.watch('src/elm', gulp.series('elmDebug'));
  gulp.watch('src/static', gulp.series('static'));
  gulp.watch('dist').on('change', browserSync.reload);
}));
