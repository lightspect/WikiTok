class WikiArticle {
  int? pageid;
  int? ns;
  String? title;
  String? extract;
  Thumbnail? thumbnail;
  String? pageimage;
  String? contentmodel;
  String? pagelanguage;
  String? pagelanguagehtmlcode;
  String? pagelanguagedir;
  String? touched;
  int? lastrevid;
  int? length;
  String? fullurl;
  String? editurl;
  String? canonicalurl;

  WikiArticle(
      {pageid,
      ns,
      title,
      extract,
      thumbnail,
      pageimage,
      contentmodel,
      pagelanguage,
      pagelanguagehtmlcode,
      pagelanguagedir,
      touched,
      lastrevid,
      length,
      fullurl,
      editurl,
      canonicalurl});

  WikiArticle.fromJson(Map<String, dynamic> json) {
    pageid = json['pageid'];
    ns = json['ns'];
    title = json['title'];
    extract = json['extract'];
    thumbnail = json['thumbnail'] != null
        ? Thumbnail.fromJson(json['thumbnail'])
        : null;
    pageimage = json['pageimage'];
    contentmodel = json['contentmodel'];
    pagelanguage = json['pagelanguage'];
    pagelanguagehtmlcode = json['pagelanguagehtmlcode'];
    pagelanguagedir = json['pagelanguagedir'];
    touched = json['touched'];
    lastrevid = json['lastrevid'];
    length = json['length'];
    fullurl = json['fullurl'];
    editurl = json['editurl'];
    canonicalurl = json['canonicalurl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['pageid'] = pageid;
    data['ns'] = ns;
    data['title'] = title;
    data['extract'] = extract;
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    data['pageimage'] = pageimage;
    data['contentmodel'] = contentmodel;
    data['pagelanguage'] = pagelanguage;
    data['pagelanguagehtmlcode'] = pagelanguagehtmlcode;
    data['pagelanguagedir'] = pagelanguagedir;
    data['touched'] = touched;
    data['lastrevid'] = lastrevid;
    data['length'] = length;
    data['fullurl'] = fullurl;
    data['editurl'] = editurl;
    data['canonicalurl'] = canonicalurl;
    return data;
  }
}

class Thumbnail {
  String? source;
  int? width;
  int? height;

  Thumbnail({source, width, height});

  Thumbnail.fromJson(Map<String, dynamic> json) {
    source = json['source'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['source'] = source;
    data['width'] = width;
    data['height'] = height;
    return data;
  }
}
