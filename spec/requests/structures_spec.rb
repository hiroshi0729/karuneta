require "rails_helper"

RSpec.describe "構成", type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  before { login(user) }

  describe "POST /posts/:post_id/structure" do
    it "テンプレートを選ぶとスライドが5枚でき、構成中になり、ネタ詳細に移動する", :aggregate_failures do
      expect { post post_structure_path(post_record), params: { template_type: "howto" } }
        .to change(post_record.slides, :count).from(0).to(5)
      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:notice]).to eq("構成を作成しました")
      expect(post_record.reload).to have_attributes(template_type: "howto", status: "drafting")
    end

    it "すでに構成があるときは作られず、元の構成のまま", :aggregate_failures do
      post_record.build_structure(:howto)
      expect { post post_structure_path(post_record), params: { template_type: "checklist" } }
        .not_to change(Slide, :count)
      expect(flash[:alert]).to eq("構成を作成できませんでした")
      expect(post_record.reload.template_type).to eq("howto")
    end

    it "不正なテンプレートだと作られない", :aggregate_failures do
      expect { post post_structure_path(post_record), params: { template_type: "unknown" } }
        .not_to change(Slide, :count)
      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:alert]).to eq("構成を作成できませんでした")
    end
  end

  describe "GET /posts/:post_id/structure/edit" do
    it "構成があれば構成エディタが表示される", :aggregate_failures do
      post_record.build_structure(:howto)
      get edit_post_structure_path(post_record)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("問題提起", "投稿準備完了にする")
    end

    it "構成がなければネタ詳細に移動し、「先に構成を作ってください」と表示される", :aggregate_failures do
      get edit_post_structure_path(post_record)
      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:alert]).to eq("先に構成を作ってください")
    end
  end

  describe "PATCH /posts/:post_id/structure" do
    let(:slide) { post_record.slides.first }

    before { post_record.build_structure(:howto) }

    def slide_params(attributes)
      { post: { slides_attributes: { "0" => { id: slide.id }.merge(attributes) } } }
    end

    it "見出しと本文が保存され、ネタ詳細に移動する", :aggregate_failures do
      patch post_structure_path(post_record), params: slide_params(heading: "表紙の見出し", body: "表紙の本文")
      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:notice]).to eq("構成を保存しました")
      expect(slide.reload).to have_attributes(heading: "表紙の見出し", body: "表紙の本文")
      expect(post_record.reload).to be_drafting
    end

    it "position・label を送っても変わらない" do
      patch post_structure_path(post_record), params: slide_params(heading: "見出し", position: 99, label: "書き換え")
      expect(slide.reload).to have_attributes(heading: "見出し", position: 1, label: "表紙")
    end

    it "見出しが101文字以上だと保存されず、構成エディタがエラーで表示される", :aggregate_failures do
      patch post_structure_path(post_record), params: slide_params(heading: "あ" * 101)
      expect(response).to have_http_status(:unprocessable_content)
      expect(slide.reload.heading).to be_nil
    end

    it "「投稿準備完了にする」で保存すると、投稿準備完了になる", :aggregate_failures do
      patch post_structure_path(post_record), params: slide_params(heading: "見出し").merge(mark_ready: "投稿準備完了にする")
      expect(flash[:notice]).to eq("構成を保存し、投稿準備完了にしました")
      expect(slide.reload.heading).to eq("見出し")
      expect(post_record.reload).to be_ready
    end
  end
end
