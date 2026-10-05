{ ... }:
{
  programs.thunderbird = {
    enable = true;

    profiles.default = {
      isDefault = true;
      # calendar list order, matching the current profile
      calendarAccountsOrder = [
        "s.fleer@famedly.com"
        "Feiertage"
      ];
      settings = {
        # no new-mail notifications
        "mail.biff.play_sound" = false;
        "mail.biff.show_alert" = false;
        "mail.biff.use_system_alert" = false;
        # never send read receipts
        "mail.mdn.report.enabled" = false;
        "mailnews.start_page.enabled" = false;
        # UI in English, fall back to German
        "intl.locale.requested" = "en-US,de";
      };
    };

    # install + enable add-ons via enterprise policy (downloaded at first start)
    policies.ExtensionSettings = {
      # https://addons.thunderbird.net/thunderbird/addon/dictionary-german/
      "de-DE@dictionaries.addons.mozilla.org" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dictionary-german/latest.xpi";
      };
    };
  };

  accounts.email.accounts."s.fleer@famedly.com" = {
    primary = true;
    address = "s.fleer@famedly.com";
    realName = "Sebastian Fleer";
    # imap.gmail.com:993 + smtp.gmail.com:465, SSL + OAuth2, is_gmail folder handling
    flavor = "gmail.com";
    thunderbird = {
      enable = true;
      settings = id: {
        "mail.smtpserver.smtp_${id}.description" = "Google Mail";
        # account-wide retention default: delete messages older than 360 days,
        # always keep starred messages (folders with "Use my account settings")
        "mail.server.server_${id}.retainBy" = 2; # nsMsgRetainByAge
        "mail.server.server_${id}.daysToKeepHdrs" = 360;
        "mail.server.server_${id}.applyToFlaggedMessages" = false;
      };
      perIdentitySettings = id: {
        # compose plain text, reply above the quote
        "mail.identity.id_${id}.compose_html" = false;
        "mail.identity.id_${id}.reply_on_top" = 1;
      };
    };
  };

  accounts.calendar.accounts = {
    "s.fleer@famedly.com" = {
      primary = true;
      remote = {
        type = "caldav";
        url = "https://apidata.googleusercontent.com/caldav/v2/s.fleer%40famedly.com/events/";
        userName = "s.fleer@famedly.com";
      };
      thunderbird = {
        enable = true;
        color = "#9FE1E7";
      };
    };

    "Feiertage" = {
      remote = {
        type = "http"; # ics subscription
        url = "https://www.thunderbird.net/media/caldata/autogen/GermanHolidays.ics";
        userName = ""; # module writes username verbatim; null would emit invalid JS
      };
      thunderbird = {
        enable = true;
        readOnly = true;
        color = "#006600";
        settings = id: {
          "calendar.registry.calendar_${id}.suppressAlarms" = true;
          "calendar.registry.calendar_${id}.refreshInterval" = "60";
        };
      };
    };
  };

  accounts.contact.accounts."s.fleer@famedly.com" = {
    remote = {
      type = "carddav";
      url = "https://www.googleapis.com/carddav/v1/principals/s.fleer%40famedly.com/lists/default/";
      userName = "s.fleer@famedly.com";
    };
    thunderbird.enable = true;
  };
}
