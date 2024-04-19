//
//  SuggestionsData.swift
//  iPad browser
//
//  Created by Caedmon Myers on 3/4/24.
//

import SwiftUI

struct SuggestionsView: View {
    @Binding var newTabSearch: String
    @State var suggestionUrls2: [String] // Declaring suggestionUrls2 as a state variable
    
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    
    @State var selectedIndex = 0

    init(newTabSearch: Binding<String>, suggestionUrls: [String]) {
        self._newTabSearch = newTabSearch
        self._suggestionUrls2 = State(initialValue: suggestionUrls) // Initializing suggestionUrls2
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                        .replacingOccurrences(of: "https://", with: "")
                        .replacingOccurrences(of: "http://", with: "")
                        .lowercased()
                        .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                        )
                }.prefix(10), id: \.self) { suggestion in
                    ZStack {
                        if suggestionUrls2.filter({ $0.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                                .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .lowercased()
                                )
                        }).prefix(10)[selectedIndex] == suggestion && selectedIndex != 11 {
                            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .leading, endPoint: .trailing)
                                .cornerRadius(7)
                                .opacity(0.75)
                        }
                        
                        Text(suggestion)
                            .opacity(0.8)
                        
                    }.frame(width: 525, height: 60)
                        .id(suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                                .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .lowercased()
                                )
                        }.prefix(10).firstIndex(of: suggestion))
                }
                Button(action: {
                    if selectedIndex < suggestionUrls2.filter({ $0.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                            )
                    }).prefix(10).count - 1 {
                        selectedIndex += 1
                    } else {
                        selectedIndex = 0
                    }
                    
                    withAnimation {
                        proxy.scrollTo(selectedIndex)
                    }
                    
//                    newTabSearch = suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
//                            .replacingOccurrences(of: "https://", with: "")
//                            .replacingOccurrences(of: "http://", with: "")
//                            .lowercased()
//                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
//                                .replacingOccurrences(of: "https://", with: "")
//                                .replacingOccurrences(of: "http://", with: "")
//                                .lowercased()
//                            )
//                    }.prefix(10)[1]
                    
                }, label: {
                }).opacity(0.0)
                    .keyboardShortcut(.downArrow, modifiers: [.command, .option])
                    .keyboardShortcut(.downArrow)
                
                Button(action: {
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    } else {
                        selectedIndex = suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                                .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .lowercased()
                                )
                        }.prefix(10).count - 1
                    }
                    
                    withAnimation {
                        proxy.scrollTo(selectedIndex)
                    }
                    
//                    newTabSearch = suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
//                            .replacingOccurrences(of: "https://", with: "")
//                            .replacingOccurrences(of: "http://", with: "")
//                            .lowercased()
//                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
//                                .replacingOccurrences(of: "https://", with: "")
//                                .replacingOccurrences(of: "http://", with: "")
//                                .lowercased()
//                            )
//                    }.prefix(10)[selectedIndex]
                }, label: {
                }).opacity(0.0)
                    .keyboardShortcut(.upArrow, modifiers: [.command, .option])
                    .keyboardShortcut(.upArrow)
            }
            .onChange(of: newTabSearch) { newValue in
                if suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                        .replacingOccurrences(of: "https://", with: "")
                        .replacingOccurrences(of: "http://", with: "")
                        .lowercased()
                        .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                        )
                }.prefix(10).count > 10 {
                    
                }
                
                selectedIndex = 0
                
                withAnimation {
                    proxy.scrollTo(selectedIndex)
                }
            }
        }
    }
}





let suggestionUrls = [
  "google.com",
  "apple.com",
  "youtube.com",
  "wikipedia.org",
  "amazon.com",
  "github.com",
  "nytimes.com",
  "notion.so",
  "linkedin.com",
  "wordpress.org",
  "support.google.com",
  "play.google.com",
  "microsoft.com",
  "docs.google.com",
  "maps.google.com",
  "en.wikipedia.org",
  "cloudflare.com",
  "whatsapp.com",
  "youtu.be",
  "plus.google.com",
  "accounts.google.com",
  "bp.blogspot.com",
  "blogspot.com",
  "mozilla.org",
  "drive.google.com",
  "europa.eu",
  "sites.google.com",
  "adobe.com",
  "googleusercontent.com",
  "facebook.com",
  "www.blogger.com",
  "istockphoto.com",
  "t.me",
  "uol.com.br",
  "policies.google.com",
  "vimeo.com",
  "gravatar.com",
  "search.google.com",
  "forbes.com",
  "dropbox.com",
  "myspace.com",
  "cnn.com",
  "medium.com",
  "gstatic.com",
  "google.com.br",
  "slideshare.net",
  "sheets.google.com",
  "etsy.com",
  "dailymotion.com",
  "google.es",
  "tiktok.com",
  "opera.com",
  "msn.com",
  "tools.google.com",
  "wa.me",
  "draft.blogger.com",
  "fr.wikipedia.org",
  "pt.wikipedia.org",
  "developers.google.com",
  "nih.gov",
  "bbc.co.uk",
  "healthline.com",
  "brandbucket.com",
  "macys.com",
  "realtor.com",
  "news.google.com",
  "creativecommons.org",
  "wikimedia.org",
  "files.wordpress.com",
  "google.de",
  "live.com",
  "craigslist.org",
  "imdb.com",
  "shopify.com",
  "line.me",
  "www.yahoo.com",
  "enable-javascript.com",
  "es.wikipedia.org",
  "feedburner.com",
  "globo.com",
  "paypal.com",
  "netvibes.com",
  "bestbuy.com",
  "who.int",
  "theguardian.com",
  "www.weebly.com",
  "mail.google.com",
  "jimdofree.com",
  "google.co.jp",
  "afternic.com",
  "youronlinechoices.com",
  "google.fr",
  "elpais.com",
  "picasaweb.google.com",
  "fb.com",
  "t.co",
  "archive.org",
  "de.wikipedia.org",
  "archiveofourown.org",
  "ru.wikipedia.org",
  "usps.com",
  "telegraph.co.uk",
  "pinterest.com",
  "mail.ru",
  "thesun.co.uk",
  "google.co.uk",
  "same.energy",
  "samsung.com",
  "webmd.com",
  "weather.com",
  "weather.gov",
  "chase.com",
  "allrecipes.com",
  "amazon.co.jp",
  "cpanel.net",
  "wsj.com",
  "cvs.com",
  "get.google.com",
  "walgreens.com",
  "independent.co.uk",
  "indeed.com",
  "www.gov.uk",
  "domainmarket.com",
  "networkadvertising.org",
  "cdc.gov",
  "hugedomains.com",
  "pixabay.com",
  "twitter.com",
  "cbsnews.com",
  "terra.com.br",
  "abril.com.br",
  "buydomains.com",
  "huffingtonpost.com",
  "nature.com",
  "booking.com",
  "w3.org",
  "reuters.com",
  "godaddy.com",
  "ebay.com",
  "wp.com",
  "adssettings.google.com",
  "marketingplatform.google.com",
  "change.org",
  "mirror.co.uk",
  "plesk.com",
  "namecheap.com",
  "forms.gle",
  "dan.com",
  "bbc.com",
  "storage.googleapis.com",
  "scribd.com",
  "time.com",
  "usatoday.com",
  "ig.com.br",
  "aboutads.info",
  "issuu.com",
  "businessinsider.com",
  "nasa.gov",
  "4shared.com",
  "amazon.co.uk",
  "cnet.com",
  "office.com",
  "foxnews.com",
  "tinyurl.com",
  "aliexpress.com",
  "photos.google.com",
  "amazon.de",
  "bloomberg.com",
  "bing.com",
  "indiatimes.com",
  "huffpost.com",
  "telegram.me",
  "myaccount.google.com",
  "goo.gl",
  "bit.ly",
  "planalto.gov.br",
  "estadao.com.br",
  "mediafire.com",
  "washingtonpost.com",
  "ytimg.com",
  "soundcloud.com",
  "shutterstock.com",
  "news.yahoo.com",
  "dailymail.co.uk",
  "instagram.com",
  "researchgate.net",
  "google.it",
  "fandom.com",
  "list-manage.com",
  "t-mobile.com",
  "un.org",
  "www.livejournal.com",
  "calendar.google.com",
  "deezer.com",
  "playstation.com",
  "google.ca",
  "berkeley.edu",
  "duckduckgo.com",
  "ted.com",
  "it.wikipedia.org",
  "abcnews.go.com",
  "smh.com.au",
  "offset.com",
  "aol.com",
  "linktr.ee",
  "canada.ca",
  "lemonde.fr",
  "yadi.sk",
  "ovh.com",
  "engadget.com",
  "psychologytoday.com",
  "sciencedirect.com",
  "apache.org",
  "imageshack.us",
  "mit.edu",
  "groups.google.com",
  "ups.com",
  "akamaihd.net",
  "wired.com",
  "clarin.com",
  "sky.com",
  "pbs.org",
  "yandex.com",
  "naver.com",
  "zippyshare.com",
  "freepik.com",
  "doubleclick.net",
  "statista.com",
  "espn.com",
  "alicdn.com",
  "20minutos.es",
  "ouest-france.fr",
  "usablenet.com",
  "whitehouse.gov",
  "instructables.com",
  "gooyaabitemplates.com",
  "translate.google.com",
  "abc.es",
  "express.co.uk",
  "alexa.com",
  "ft.com",
  "elmundo.es",
  "marca.com",
  "cpanel.com",
  "gofundme.com",
  "cornell.edu",
  "pinterest.fr",
  "google.pl",
  "discord.gg",
  "timeweb.ru",
  "finance.yahoo.com",
  "e-monsite.com",
  "akamaized.net",
  "vice.com",
  "redbull.com",
  "unesco.org",
  "rapidshare.com",
  "prezi.com",
  "000webhost.com",
  "sapo.pt",
  "nikkei.com",
  "springer.com",
  "netlify.app",
  "search.yahoo.com",
  "cambridge.org",
  "bp2.blogger.com",
  "ea.com",
  "taringa.net",
  "lavanguardia.com",
  "ikea.com",
  "qq.com",
  "id.wikipedia.org",
  "zillow.com",
  "mozilla.com",
  "amazon.fr",
  "nypost.com",
  "weibo.com",
  "www.canalblog.com",
  "photobucket.com",
  "yelp.com",
  "gizmodo.com",
  "quora.com",
  "sakura.ne.jp",
  "unsplash.com",
  "detik.com",
  "android.com",
  "code.google.com",
  "addtoany.com",
  "pexels.com",
  "hindustantimes.com",
  "nbcnews.com",
  "goodreads.com",
  "wellsfargo.com",
  "wikia.com",
  "dw.com",
  "yandex.ru",
  "theatlantic.com",
  "windows.net",
  "ggpht.com",
  "privacyshield.gov",
  "discord.com",
  "doi.org",
  "www.wix.com",
  "www.gov.br",
  "leparisien.fr",
  "books.google.com",
  "nydailynews.com",
  "ipv4.google.com",
  "mashable.com",
  "rtve.es",
  "insider.com",
  "sciencedaily.com",
  "bloglovin.com",
  "urbandictionary.com",
  "rakuten.co.jp",
  "hulu.com",
  "gnu.org",
  "plos.org",
  "hubspot.com",
  "spiegel.de",
  "google.nl",
  "cnil.fr",
  "sedo.com",
  "ziddu.com",
  "steampowered.com",
  "capitalone.com",
  "costco.com",
  "rt.com",
  "icann.org",
  "kickstarter.com",
  "francetvinfo.fr",
  "npr.org",
  "cointernet.com.co",
  "nationalgeographic.com",
  "latimes.com",
  "outlook.com",
  "spotify.com",
  "ria.ru",
  "cbc.ca",
  "guardian.co.uk",
  "cnbc.com",
  "ovhcloud.com",
  "tripadvisor.com",
  "nginx.com",
  "oracle.com",
  "yahoo.co.jp",
  "britannica.com",
  "huawei.com",
  "buzzfeed.com",
  "techcrunch.com",
  "zoom.us",
  "wiley.com",
  "home.pl",
  "homedepot.com",
  "standard.co.uk",
  "photos1.blogger.com",
  "newyorker.com",
  "secureserver.net",
  "hp.com",
  "ietf.org",
  "sendspace.com",
  "amazon.es",
  "oup.com",
  "tmz.com",
  "m.wikipedia.org",
  "bandcamp.com",
  "economist.com",
  "ssl-images-amazon.com",
  "target.com",
  "webnode.page",
  "walmart.com",
  "surveymonkey.com",
  "ovh.net",
  "abc.net.au",
  "newsweek.com",
  "zendesk.com",
  "nginx.org",
  "dreamstime.com",
  "ca.gov",
  "ja.wikipedia.org",
  "clickbank.net",
  "nextdoor.com",
  "bankofamerica.com",
  "hollywoodreporter.com",
  "academia.edu",
  "biglobe.ne.jp",
  "liveinternet.ru",
  "sfgate.com",
  "roblox.com",
  "google.ru",
  "gmail.com",
  "ftc.gov",
  "netflix.com"
]
