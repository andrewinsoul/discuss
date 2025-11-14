// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()


const createCommentSocket = (topicId) => {
  const channel = socket.channel(`comment:${topicId}`, {});
  channel
    .join()
    .receive("ok", (_resp) => {
      console.log('successfully joined comment channel for real time update!');

    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  channel.on(`comment:${topicId}:new`, async (response) => {
    const dateCommentWasCreated = response.comment.inserted_at
    if (document.querySelector("textarea")) document.querySelector("textarea").value = ""
    document.getElementById("comment-list").innerHTML += `
    <div class="border-b border-gray-200 pb-4 last:pb-12 last:mb-20">
      <p>${response.comment.content}</p>
      <small>By ${response.comment.user.username} ${dateCommentWasCreated}</small>
    </div>`;
    const box = document.getElementById("comment-list");
    box.scrollTop = box.scrollHeight;
    requestAnimationFrame(() => {
      box.scrollTo({ top: box.scrollHeight, behavior: 'smooth' })
    });
  });
  return channel
};

window.createCommentSocket = createCommentSocket;

export default socket
