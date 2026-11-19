// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

// data-turbo-confirm の確認を、ブラウザ標準の confirm ではなくレイアウトの <dialog> で表示する
// （Turbo 8 では Turbo.config.forms.confirm が推奨。setConfirmMethod は非推奨）
Turbo.config.forms.confirm = (message) => {
  const dialog = document.getElementById("confirm-dialog")
  if (!dialog) return Promise.resolve(window.confirm(message))

  // HTML として解釈させないよう textContent で入れる
  dialog.querySelector("[data-confirm-message]").textContent = message
  dialog.returnValue = ""
  dialog.showModal()

  // 「削除する」のときだけ returnValue が "confirm" になる（キャンセル・Esc・背景クリックは false）
  return new Promise((resolve) => {
    dialog.addEventListener("close", () => resolve(dialog.returnValue === "confirm"), { once: true })
  })
}

// 背景（カードの外側）をクリックしたら閉じる
document.addEventListener("click", (event) => {
  if (event.target.id === "confirm-dialog") event.target.close()
})
