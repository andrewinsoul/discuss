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
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { createIcons, icons } from "lucide";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import advancedFormat from "dayjs/plugin/advancedFormat";

document.addEventListener("DOMContentLoaded", () => {
  createIcons({ icons });
});

dayjs.extend(relativeTime);
dayjs.extend(advancedFormat)

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

let currentTopicId = null;
let socket = new Socket("/socket", { params: { token: window.userToken } });

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

window.deleteTopic = () => {
  document.getElementById(`delete-topic-form-${currentTopicId}`).submit();
  document.getElementById("confirm-modal").style.display = "none";
};

document.addEventListener("click", function (event) {
  if (event.target.closest(".confirm-delete")) {
    let button = event.target.closest(".confirm-delete");
    const topicName = button.dataset.title;
    const topicId = button.id;
    currentTopicId = topicId;

    document.getElementById(
      "modal-question"
    ).innerText = `Are you sure you want to \
      delete topic: "${topicName}"?`;
    document.getElementById("confirmModal").style.display = "flex";
  } else if (
    event.target.id === "handleCancel" ||
    event.target.className.includes("close")
  ) {
    document.getElementById("confirmModal").style.display = "none";
  }
});

// connect if there are any LiveViews on the page
liveSocket.connect();
socket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

const checkIsOlderThanWeek = (date) => {
  const now = dayjs();
  return now.diff(date, "week") >= 1;
};

const formatDateCommentWasCreated = (date) => {
  return checkIsOlderThanWeek(date)
    ? dayjs(date).format("Do MMMM, YYYY HH:mm")
    : dayjs(date).fromNow();
};

const createSocket = (topicId) => {
  const channel = socket.channel(`comment:${topicId}`, {});
  channel
    .join()
    .receive("ok", (resp) => {
      renderCommentArray(resp.comments);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  document.getElementById("add-comment-btn").addEventListener("click", () => {
    const content = document.querySelector("textarea").value;
    channel.push("comment:add", { content: content });
  });

  channel.on(`comment:${topicId}:new`, (response) => {
    const dateCommentWasCreated = formatDateCommentWasCreated(
      response.comment.inserted_at
    );
    document.querySelector("textarea").value = ""
    document.getElementById("comment-list").innerHTML += `
    <li class="mb-4">
      <p>${response.comment.content}</p>
      <p class="text-xs text-gray-400">${dateCommentWasCreated}</p>
    </li>`;
  });
};

function renderCommentArray(commentArray) {
  const renderedComments = commentArray.map((comment) => {
    const dateCommentWasCreated = formatDateCommentWasCreated(
      comment.inserted_at
    );
    return `
    <li class="mb-4">
      <p>${comment.content}</p>
      <p class="text-xs text-gray-400">${dateCommentWasCreated}</p>
    </li>`;
  });
  document.getElementById("comment-list").innerHTML = renderedComments.join("");
}

window.createSocket = createSocket;
