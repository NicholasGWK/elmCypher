const Koa = require('koa');
const serve = require('koa-static');
const mount = require('koa-mount');

const app = new Koa();

app.use(mount('/', serve(__dirname + '/src')));
console.log('Serving on port 3000');
app.listen( process.env.PORT || 3000 )
