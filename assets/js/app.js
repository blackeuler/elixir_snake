// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
//Snake Hook Stuff
let Hooks = {}

    Hooks.canvas =  {
        mounted() {

            let canvas = this.el.firstElementChild;
            const snakes = JSON.parse(this.el.dataset.snakes)
            const blockSize = JSON.parse(this.el.dataset.block) || 10

            let ctx = canvas.getContext("2d");
            let cameraX = snakes[0].head.x - canvas.width / 2;
            let cameraY = snakes[0].head.y - canvas.height / 2;

                // Translate the canvas context to the new camera position
            ctx.translate(-cameraX, -cameraY);
            // Wall
            const canvasWidth = canvas.width;
            const canvasHeight = canvas.height;
            const widthInBlocks = canvasWidth / blockSize;
            const heightInBlocks = canvasHeight / blockSize;
            console.log(snakes)

            this.el.addEventListener('mousemove', e => {
             const dx = e.clientX - snakes[0].head.x;
             const dy = e.clientY - snakes[0].head.y;
                const angle = Math.atan2(dy,dx);
                console.log(angle)
                this.pushEvent("angle_change", {angle });
            });
            // canvas.addEventListener('mousemove', function(event) {
            // // Calculate the angle between the mouse position and the snake's head position
            // const dx = event.clientX - snakes[0].x;
            // const dy = event.clientY - snakes[0].y;
            //     pushEvent("angle_change",{angle:  Math.atan2(dy, dx)},() => console.log("Whoops"));
            // });


            function drawSnake(snake) {
                ctx.fillStyle = snake.color;
                ctx.fillRect( snake.head.x * blockSize,snake.head.y * blockSize,blockSize,blockSize);
            }
            snakes.forEach(snake => drawSnake(snake) );


            Object.assign(this, {canvas,ctx,snakes,blockSize, drawSnake});
        },
        updated() {
            let {canvas, ctx, blockSize} = this;
            //ctx.clearRect(0,0,canvas.width,canvas.height)



            function drawSnake(snake) {
                ctx.fillStyle = snake.color;
                ctx.fillRect( snake.head.x * blockSize,snake.head.y * blockSize,blockSize,blockSize);
            }
            let snakes = JSON.parse(this.el.dataset.snakes)
            let cameraX = snakes[0].head.x - canvas.width / 2;
            let cameraY = snakes[0].head.y - canvas.height / 2;

                // Translate the canvas context to the new camera position
            ctx.translate(-cameraX, -cameraY);
            for (var i = 0; i < snakes.length; ++i) {
                ctx.fillStyle = "red";
                ctx.fillRect( snakes[i].head.x * blockSize,snakes[i].head.y * blockSize,blockSize,blockSize);

            }
    }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken},hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())






// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
//liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

