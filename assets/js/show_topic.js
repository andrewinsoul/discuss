document.addEventListener("DOMContentLoaded", function () {
    console.log("🟢 DOM Content Loaded");
    const btn = document.getElementById("add-comment-btn");
    const textareaElem = document.querySelector('textarea')
    const errorMsgContainer = document.getElementById("error-msg-cont")
    const errorSection = document.getElementById("error-msg")
    const mainElement = document.querySelector('main[data-topic-id]');
    
    const topicId = mainElement.dataset.topicId;
    
    const channel = window.createCommentSocket(topicId)
    if (textareaElem) {
      textareaElem.addEventListener("change", function() {
        if (this.value.length > 0 || this.value.trim().length > 0 ) {
          errorMsgContainer.style.display = "none"
          errorSection.innerHTML = ""
        }
      });
    }

    if (btn) {
      btn.addEventListener('click', function() {
        const content = textareaElem.value
        channel.push("comment:add", { content })
          .receive("ok", (resp) => {
            console.log("✅ sucess >>>> ", resp.message)
          })
          .receive("error", (resp) => {
            if (resp.errors && resp.errors.content) {
              errorMsgContainer.style.display = "flex"
              const errorHTML = resp.errors.content.map(errorMsg =>
                  `<p>${errorMsg}</p>`
                ).join('');
              errorSection.innerHTML = errorHTML
            }
          })
      })
    }
  })