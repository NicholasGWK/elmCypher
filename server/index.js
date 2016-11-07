const Koa = require('koa');
const serve = require('koa-static');
const mount = require('koa-mount');
const path = require('path');
const app = new Koa();


const clientPath = path.join(__dirname, '../' + 'src');
console.log(clientPath);
app.use(mount('/', serve(clientPath)));
console.log('Serving on port 3000');
app.listen(3000)
