require "rails_helper"

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  describe "バリデーション" do
    it "タイトルだけで有効" do
      expect(described_class.new(user: user, title: "ネタのタイトル")).to be_valid
    end

    it "タイトルが空だと無効" do
      expect(build(:post, title: "")).not_to be_valid
    end

    it "タイトルが100文字なら有効" do
      expect(build(:post, title: "あ" * 100)).to be_valid
    end

    it "タイトルが101文字以上だと無効" do
      expect(build(:post, title: "あ" * 101)).not_to be_valid
    end

    it "メモが1000文字なら有効" do
      expect(build(:post, memo: "あ" * 1000)).to be_valid
    end

    it "メモが1001文字以上だと無効" do
      expect(build(:post, memo: "あ" * 1001)).not_to be_valid
    end

    it "自分のカテゴリを指定すると有効" do
      expect(build(:post, user: user, category: create(:category, user: user))).to be_valid
    end

    it "ほかの人のカテゴリを指定すると無効" do
      expect(build(:post, user: user, category: create(:category))).not_to be_valid
    end

    it "不正なステータスだと無効" do
      expect(build(:post, status: "unknown")).not_to be_valid
    end
  end

  describe "初期値" do
    it "作った直後のステータスは idea、template_type は nil", :aggregate_failures do
      post = create(:post)
      expect(post).to be_idea
      expect(post.template_type).to be_nil
    end
  end

  describe ".with_status" do
    let!(:idea_post) { create(:post, status: :idea) }
    let!(:drafting_post) { create(:post, status: :drafting) }

    it "正しい値なら、そのステータスのネタだけに絞り込める" do
      expect(described_class.with_status("drafting")).to contain_exactly(drafting_post)
    end

    it "空なら全件を返す" do
      expect(described_class.with_status("")).to contain_exactly(idea_post, drafting_post)
    end

    it "nil なら全件を返す" do
      expect(described_class.with_status(nil)).to contain_exactly(idea_post, drafting_post)
    end

    it "不正な値なら全件を返す" do
      expect(described_class.with_status("unknown")).to contain_exactly(idea_post, drafting_post)
    end
  end

  describe "予定日での並び替え" do
    let!(:posts) do
      today = Date.current
      {
        no_schedule: create(:post, scheduled_on: nil, created_at: 3.days.ago),
        later: create(:post, scheduled_on: today + 5, created_at: 3.days.ago),
        sooner_old: create(:post, scheduled_on: today + 1, created_at: 2.days.ago),
        sooner_new: create(:post, scheduled_on: today + 1, created_at: 1.day.ago),
        past: create(:post, scheduled_on: today - 1, created_at: 3.days.ago)
      }
    end

    describe ".by_schedule" do
      it "予定日が近い順（予定日なしは最後）、同じ予定日なら新しく登録した順に並ぶ" do
        expect(described_class.by_schedule)
          .to eq(posts.values_at(:past, :sooner_new, :sooner_old, :later, :no_schedule))
      end
    end

    describe ".upcoming" do
      it "予定日の古い順（過ぎたものも含む）、同じ予定日なら新しく登録した順に並び、予定日なしは入らない" do
        expect(described_class.upcoming).to eq(posts.values_at(:past, :sooner_new, :sooner_old, :later))
      end

      it "投稿済みのネタは入らない" do
        posted = create(:post, status: :posted, scheduled_on: Date.current + 1)
        expect(described_class.upcoming).not_to include(posted)
      end
    end
  end

  describe ".recently_updated" do
    it "最近更新した順に並ぶ" do
      older = create(:post, updated_at: 2.days.ago)
      newer = create(:post, updated_at: 1.day.ago)
      expect(described_class.recently_updated).to eq([ newer, older ])
    end
  end

  describe "#structure_created?" do
    it "構成を作る前は false" do
      expect(create(:post).structure_created?).to be false
    end

    it "構成を作ったあとは true" do
      post = create(:post).tap { |p| p.build_structure(:howto) }
      expect(post.structure_created?).to be true
    end
  end

  describe "#can_mark_ready?" do
    { idea: true, drafting: true, ready: false, posted: false }.each do |status, expected|
      it "#{status} のときは #{expected}" do
        expect(build(:post, status: status).can_mark_ready?).to be expected
      end
    end
  end

  describe "投稿日（posted_on）の記録" do
    around { |example| travel_to(Date.new(2026, 11, 23)) { example.run } }

    let(:post) { create(:post, status: :ready) }

    it "posted にすると今日の日付が入る" do
      post.update!(status: :posted)
      expect(post.posted_on).to eq(Date.new(2026, 11, 23))
    end

    it "すでに投稿日が入っていれば、posted にしても上書きしない" do
      post.update!(posted_on: Date.new(2026, 11, 1))
      post.update!(status: :posted)
      expect(post.posted_on).to eq(Date.new(2026, 11, 1))
    end

    it "posted 以外に戻すと投稿日が空になる" do
      post.update!(status: :posted)
      post.update!(status: :ready)
      expect(post.posted_on).to be_nil
    end

    it "ステータスを変えなければ投稿日は変わらない" do
      post.update!(status: :posted)
      expect { post.update!(title: "新しいタイトル") }.not_to change(post, :posted_on)
    end
  end

  describe "#build_structure" do
    let(:post) { create(:post) }

    it "howto で、ラベル付きのスライドが5枚でき、ステータスが drafting になる", :aggregate_failures do
      expect(post.build_structure("howto")).to be true
      expect(post.reload.slides.map { |slide| [ slide.position, slide.label ] })
        .to eq([ [ 1, "表紙" ], [ 2, "問題提起" ], [ 3, "原因・解説" ], [ 4, "解決策" ], [ 5, "CTA" ] ])
      expect(post).to have_attributes(template_type: "howto", status: "drafting")
    end

    it "checklist で、ラベル付きのスライドが5枚でき、ステータスが drafting になる", :aggregate_failures do
      expect(post.build_structure(:checklist)).to be true
      expect(post.reload.slides.map(&:label)).to eq(%w[表紙 チェック項目1 チェック項目2 チェック項目3 まとめ・CTA])
      expect(post).to have_attributes(template_type: "checklist", status: "drafting")
    end

    [ "unknown", "", nil ].each do |invalid_type|
      it "#{invalid_type.inspect} を渡すと false を返し、何も変わらない", :aggregate_failures do
        expect(post.build_structure(invalid_type)).to be false
        expect(post.reload).to have_attributes(template_type: nil, status: "idea")
        expect(post.slides).to be_empty
      end
    end

    it "すでに構成があるときは false を返し、何も変わらない", :aggregate_failures do
      post.build_structure(:howto)
      expect(post.build_structure(:checklist)).to be false
      expect(post.reload.template_type).to eq("howto")
      expect(post.slides.count).to eq(5)
    end
  end

  describe "#update_structure" do
    let(:post) { create(:post).tap { |post| post.build_structure(:howto) } }
    let(:first_slide) { post.slides.first }
    let(:valid_attributes) do
      { slides_attributes: [ { id: first_slide.id, heading: "見出し1", body: "本文1" } ] }
    end

    it "見出し・本文が保存される", :aggregate_failures do
      expect(post.update_structure(valid_attributes)).to be true
      expect(first_slide.reload).to have_attributes(heading: "見出し1", body: "本文1")
      expect(post.reload).to be_drafting
    end

    it "mark_ready: true なら見出し・本文が保存され、ready になる", :aggregate_failures do
      expect(post.update_structure(valid_attributes, mark_ready: true)).to be true
      expect(first_slide.reload.heading).to eq("見出し1")
      expect(post.reload).to be_ready
    end

    it "posted のネタは mark_ready: true でもステータスが戻らない" do
      post.update!(status: :posted)
      post.update_structure(valid_attributes, mark_ready: true)
      expect(post.reload).to be_posted
    end

    it "ready のネタは mark_ready: true のままステータスが変わらない" do
      post.update!(status: :ready)
      post.update_structure(valid_attributes, mark_ready: true)
      expect(post.reload).to be_ready
    end

    it "見出しが101文字以上なら false を返し、ほかのスライドもステータスも保存されない", :aggregate_failures do
      second_slide = post.slides.second
      attributes = [ { id: first_slide.id, heading: "見出し1" }, { id: second_slide.id, heading: "あ" * 101 } ]
      expect(post.update_structure({ slides_attributes: attributes }, mark_ready: true)).to be false
      expect([ first_slide.reload.heading, second_slide.reload.heading ]).to eq([ nil, nil ])
      expect(post.reload).to be_drafting
    end

    it "失敗したとき、画面に出すステータスは元のまま", :aggregate_failures do
      attributes = { slides_attributes: [ { id: first_slide.id, heading: "あ" * 101 } ] }
      expect(post.update_structure(attributes, mark_ready: true)).to be false
      expect(post).to be_drafting
    end
  end

  describe "#change_status" do
    let(:post) { create(:post, status: :drafting) }

    it "ready に変えられる", :aggregate_failures do
      expect(post.change_status("ready")).to be true
      expect(post.reload).to be_ready
    end

    it "posted に変えられる", :aggregate_failures do
      expect(post.change_status("posted")).to be true
      expect(post.reload).to be_posted
    end

    [ "idea", "drafting", "unknown", "", nil ].each do |new_status|
      it "#{new_status.inspect} には変えられず false を返す", :aggregate_failures do
        expect(post.change_status(new_status)).to be false
        expect(post.reload).to be_drafting
      end
    end
  end

  describe "削除" do
    it "ネタを削除するとスライドも削除される" do
      post = create(:post).tap { |p| p.build_structure(:howto) }
      expect { post.destroy }.to change(Slide, :count).by(-5)
    end
  end
end
