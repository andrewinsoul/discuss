// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix"
// import dayjs from "dayjs";
// import relativeTime from "dayjs/plugin/relativeTime";
// import advancedFormat from "dayjs/plugin/advancedFormat";

// dayjs.extend(relativeTime);
// dayjs.extend(advancedFormat)

// And connect to the path in "lib/discuss_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", { params: { token: window.userToken } })

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/discuss_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/discuss_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/discuss_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
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
    // const dateCommentWasCreated = formatDateCommentWasCreated(
    //   response.comment.inserted_at
    // );
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

// const checkIsOlderThanWeek = (date) => {
//   const now = dayjs();
//   return now.diff(date, "week") >= 1;
// };

// const formatDateCommentWasCreated = (date) => {
//   return checkIsOlderThanWeek(date)
//     ? dayjs(date).format("Do MMMM, YYYY HH:mm")
//     : dayjs(date).fromNow();
// };

window.createCommentSocket = createCommentSocket;

export default socket
