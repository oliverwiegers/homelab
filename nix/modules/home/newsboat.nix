{
  lib,
  config,
  ...
}:
let
  cfg = config.terminal.programs.newsboat;
in
{
  options.terminal.programs.newsboat = {
    enable = lib.mkEnableOption "Enable newsboat.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      newsboat = {
        enable = true;
        autoReload = true;
        reloadThreads = 4;
        reloadTime = 120;
        browser = ''"w3m %u"'';

        extraConfig = ''
          download-retries 4
          download-timeout 10
          prepopulate-query-feeds yes

          # Visuals
          show-read-feeds yes
          show-read-articles no
          article-sort-order date-desc

          color info black white reverse
          color listnormal_unread yellow default
          color listfocus green default reverse bold
          color listfocus_unread green default reverse bold

          text-width 80
          feedlist-format "%?T?%  %n %8u %t &--------------------------------------------------------------- %t?"

          # Vim like keybindings.
          bind-key j down all
          bind-key k up all
          bind-key J next-feed articlelist
          bind-key K prev-feed articlelist
          bind-key g home all
          bind-key G end all

          # UX
          goto-next-feed no
          confirm-exit no
          cleanup-on-quit yes
          confirm-mark-feed-read no
          notify-program '/bin/notify-send'

          # Macros
          macro f set browser "firefox %u"; open-in-browser-and-mark-read ; set browser "w3m %u"
          macro w set browser "~/.local/bin/wallabag add %u"; open-in-browser-and-mark-read ; set browser "/bin/w3m %u"
        '';

        urls = [
          # News Aggregators
          { url = ''"query:News Aggregators:tags # \"news_aggregator\""''; }
          {
            url = "https://feeds.feedburner.com/TheHackersNews";
            tags = [
              "news_aggregator"
              "cybersecurity"
            ];
          }
          {
            url = "https://news.ycombinator.com/rss";
            tags = [
              "news_aggregator"
              "~Hacker News (ycombinator)"
            ];
          }
          {
            url = "https://lobste.rs/rss";
            tags = [ "news_aggregator" ];
          }

          # Blogs
          { url = ''"query:Blogs:tags # \"blog\""''; }
          {
            url = "https://hackerstations.substack.com/feed/";
            tags = [ "blog" ];
          }
          {
            url = "https://blog.orhun.dev/rss.xml";
            tags = [
              "blog"
              "~Orhun's Blog (Programming)"
              "programming"
            ];
          }
          {
            url = "https://ersei.net/en/blog.atom";
            tags = [ "blog" ];
          }
          {
            url = "https://danielmiessler.com/feed";
            tags = [
              "blog"
              "cybersecurity"
            ];
          }
          {
            url = "https://blog.python.org/feeds/posts/default?alt=rss";
            tags = [
              "blog"
              "programming"
              "python"
            ];
          }
          {
            url = "https://garrit.xyz/rss.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://fasterthanli.me/index.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://taylor.town/feed";
            tags = [ "blog" ];
          }
          {
            url = "https://www.claudiokuenzler.com/rss.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://www.mevlyshkin.com/blog/atom.xml";
            tags = [
              "blog"
              "maybe"
            ];
          }
          {
            url = "http://feeds.scottlowe.org/slowe/content/feed/";
            tags = [
              "blog"
              "kubernetes"
            ];
          }
          {
            url = "https://bitecode.substack.com/feed/";
            tags = [
              "blog"
              "programming"
              "python"
            ];
          }
          {
            url = "https://samwho.dev/rss.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://kmaasrud.com/atom.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://opensourcemusings.com/feed/";
            tags = [ "blog" ];
          }
          {
            url = "https://dqdongg.com/rss.xml";
            tags = [
              "blog"
              "programming"
              "python"
            ];
          }
          {
            url = "https://frankindev.com/feed.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://ounapuu.ee/index.xml";
            tags = [
              "blog"
              "linux"
            ];
          }
          {
            url = "https://ma.ttias.be/blog/index.xml";
            tags = [
              "blog"
              "linux"
            ];
          }
          {
            url = "https://privsec.dev/index.xml";
            tags = [
              "blog"
              "security"
            ];
          }
          {
            url = "https://matduggan.com/rss/";
            tags = [
              "blog"
              "~Mat Duggan"
            ];
          }
          {
            url = "https://alexharv074.github.io/feed.xml";
            tags = [
              "blog"
              "programming"
            ];
          }
          {
            url = "https://lazybear.io/index.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://shellsharks.com/feed";
            tags = [
              "blog"
              "security"
            ];
          }
          {
            url = "https://0xash.io/feed";
            tags = [
              "blog"
              "security"
            ];
          }
          {
            url = "https://ianthehenry.com/feed.xml";
            tags = [ "blog" ];
          }
          {
            url = "https://ludic.mataroa.blog/rss/";
            tags = [ "blog" ];
          }
          {
            url = "https://gvolpe.com/blog/feed.xml";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://fasterthanli.me/index.xml";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://jdisaacs.com/blog/rss.xml";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://thiscute.world/en/index.xml";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://xeiaso.net/blog.rss";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://lhf.pt/atom.xml";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://primamateria.github.io/blog/atom.xml";
            tags = [
              "blog"
              "nix"
            ];
          }
          {
            url = "https://stephank.nl/index.rss";
            tags = [
              "blog"
              "nix"
            ];
          }

          # Corporate Blogs
          { url = ''"query:Corporate Blogs:tags # \"corporate_blog\""''; }
          {
            url = "https://googleonlinesecurity.blogspot.com/atom.xml";
            tags = [
              "corporate_blog"
              "cybersecurity"
            ];
          }
          {
            url = "https://www.pulumi.com/blog/rss.xml";
            tags = [
              "corporate_blog"
              "infrastructure"
            ];
          }
          {
            url = "https://blog.python.org/feeds/posts/default?alt=rss";
            tags = [
              "corporate_blog"
              "programming"
            ];
          }
          {
            url = "https://blog.pypi.org/feed_rss_created.xml";
            tags = [
              "corporate_blog"
              "programming"
            ];
          }
          {
            url = "https://serokell.io/blog.rss.xml";
            tags = [
              "corporate_blog"
              "nix"
            ];
          }
          {
            url = "https://determinate.systems/rss.xml";
            tags = [
              "corporate_blog"
              "nix"
            ];
          }

          # Misc
          { url = ''"query:Misc:tags # \"misc\""''; }
          {
            url = "http://www.python.org/dev/peps/peps.rss";
            tags = [
              "misc"
              "programming"
              "python"
            ];
          }
          {
            url = "http://wikileaks.org/feed-all";
            tags = [ "misc" ];
          }
          {
            url = "https://www.rfc-editor.org/rfcrss.xml";
            tags = [ "misc" ];
          }
          {
            url = "https://www.w3.org/blog/news/feed";
            tags = [ "misc" ];
          }
          {
            url = "https://hacks.mozilla.org/feed/";
            tags = [ "misc" ];
          }
          {
            url = "https://nyxt.atlas.engineer/feed";
            tags = [
              "misc"
              "changelog"
            ];
          }

          # Gaming
          { url = ''"query:Gaming:tags # \"gaming\""''; }
          {
            url = "http://feeds.feedburner.com/MajorNelson";
            tags = [ "gaming" ];
          }
        ];
      };
    };
  };
}
