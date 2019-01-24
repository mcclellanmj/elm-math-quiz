var gulp = require('gulp');
var elm  = require('gulp-elm');
var browserSync = require('browser-sync').create();

gulp.task('static', function() {
  return gulp.src('src/static/**', { base: 'src/static' })
    .pipe(gulp.dest('dist/'));
});

gulp.task('elm', function(){
  return gulp.src('src/elm/Main.elm')
    .pipe(elm.bundle('elm.js', { debug: true }))
    .pipe(gulp.dest('dist/'));
});

gulp.task('serve', gulp.series('static', 'elm', function() {
  browserSync.init({
    server: 'dist/',
    cors: true
  });

  gulp.watch('src/elm', gulp.series('elm'));
  gulp.watch('src/static', gulp.series('static'));
  gulp.watch('dist').on('change', browserSync.reload);
}));
