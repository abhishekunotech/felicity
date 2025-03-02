/*
 Highcharts JS v6.1.0 (2018-04-13)
 Exporting module

 (c) 2010-2017 Torstein Honsi

 License: www.highcharts.com/license
*/
(function(q) {
    "object" === typeof module && module.exports ? module.exports = q : q(Highcharts)
})(function(q) {
    (function(a) {
        a.ajax = function(z) {
            var c = a.merge(!0, {
                url: !1,
                type: "GET",
                dataType: "json",
                success: !1,
                error: !1,
                data: !1,
                headers: {}
            }, z);
            z = {
                json: "application/json",
                xml: "application/xml",
                text: "text/plain",
                octet: "application/octet-stream"
            };
            var m = new XMLHttpRequest;
            if (!c.url) return !1;
            m.open(c.type.toUpperCase(), c.url, !0);
            m.setRequestHeader("Content-Type", z[c.dataType] || z.text);
            a.objectEach(c.headers, function(a, c) {
                m.setRequestHeader(c,
                    a)
            });
            m.onreadystatechange = function() {
                var a;
                if (4 === m.readyState) {
                    if (200 === m.status) {
                        a = m.responseText;
                        if ("json" === c.dataType) try {
                            a = JSON.parse(a)
                        } catch (e) {
                            c.error && c.error(m, e);
                            return
                        }
                        return c.success && c.success(a)
                    }
                    c.error && c.error(m, m.responseText)
                }
            };
            try {
                c.data = JSON.stringify(c.data)
            } catch (u) {}
            m.send(c.data || !0)
        }
    })(q);
    (function(a) {
        var z = a.defined,
            c = a.each,
            m = a.pick,
            u = a.win,
            e = u.document,
            n = a.seriesTypes,
            q = void 0 !== e.createElement("a").download;
        a.setOptions({
            exporting: {
                csv: {
                    columnHeaderFormatter: null,
                    dateFormat: "%Y-%m-%d %H:%M:%S",
                    decimalPoint: null,
                    itemDelimiter: null,
                    lineDelimiter: "\n"
                },
                showTable: !1,
                useMultiLevelHeaders: !0,
                useRowspanHeaders: !0
            },
            lang: {
                downloadCSV: "Download CSV",
                downloadXLS: "Download XLS",
                //openInCloud: "Open in Highcharts Cloud",
                viewData: "View data table"
            }
        });
        a.addEvent(a.Chart, "render", function() {
            this.options && this.options.exporting && this.options.exporting.showTable && this.viewData()
        });
        a.Chart.prototype.setUpKeyToAxis = function() {
            n.arearange && (n.arearange.prototype.keyToAxis = {
                low: "y",
                high: "y"
            })
        };
        a.Chart.prototype.getDataRows =
            function(f) {
                var g = this.time,
                    h = this.options.exporting && this.options.exporting.csv || {},
                    d, l = this.xAxis,
                    r = {},
                    e = [],
                    p, D = [],
                    v = [],
                    A, w, k, E = function(b, d, k) {
                        if (h.columnHeaderFormatter) {
                            var g = h.columnHeaderFormatter(b, d, k);
                            if (!1 !== g) return g
                        }
                        return b ? b instanceof a.Axis ? b.options.title && b.options.title.text || (b.isDatetimeAxis ? "DateTime" : "Category") : f ? {
                            columnTitle: 1 < k ? d : b.name,
                            topLevelColumnTitle: b.name
                        } : b.name + (1 < k ? " (" + d + ")" : "") : "Category"
                    },
                    B = [];
                w = 0;
                this.setUpKeyToAxis();
                c(this.series, function(b) {
                    var d = b.options.keys ||
                        b.pointArrayMap || ["y"],
                        k = d.length,
                        x = !b.requireSorting && {},
                        p = {},
                        e = {},
                        y = a.inArray(b.xAxis, l),
                        n, t;
                    c(d, function(d) {
                        var a = (b.keyToAxis && b.keyToAxis[d] || d) + "Axis";
                        p[d] = b[a] && b[a].categories || [];
                        e[d] = b[a] && b[a].isDatetimeAxis
                    });
                    if (!1 !== b.options.includeInCSVExport && !b.options.isInternal && !1 !== b.visible) {
                        a.find(B, function(b) {
                            return b[0] === y
                        }) || B.push([y, w]);
                        for (t = 0; t < k;) A = E(b, d[t], d.length), v.push(A.columnTitle || A), f && D.push(A.topLevelColumnTitle || A), t++;
                        n = {
                            chart: b.chart,
                            autoIncrement: b.autoIncrement,
                            options: b.options,
                            pointArrayMap: b.pointArrayMap
                        };
                        c(b.options.data, function(a, f) {
                            var c, l;
                            l = {
                                series: n
                            };
                            b.pointClass.prototype.applyOptions.apply(l, [a]);
                            a = l.x;
                            x && (x[a] && (a += "|" + f), x[a] = !0);
                            t = 0;
                            r[a] || (r[a] = [], r[a].xValues = []);
                            r[a].x = l.x;
                            r[a].xValues[y] = l.x;
                            b.xAxis && "name" !== b.exportKey || (r[a].name = b.data[f] && b.data[f].name);
                            for (; t < k;) f = d[t], c = l[f], r[a][w + t] = m(p[f][c], e[f] ? g.dateFormat(h.dateFormat, c) : null, c), t++
                        });
                        w += t
                    }
                });
                for (p in r) r.hasOwnProperty(p) && e.push(r[p]);
                var x, y;
                p = f ? [D, v] : [v];
                for (w = B.length; w--;) x = B[w][0],
                    y = B[w][1], d = l[x], e.sort(function(b, a) {
                        return b.xValues[x] - a.xValues[x]
                    }), k = E(d), p[0].splice(y, 0, k), f && p[1] && p[1].splice(y, 0, k), c(e, function(b) {
                        var a = b.name;
                        d && !z(a) && (d.isDatetimeAxis ? (b.x instanceof Date && (b.x = b.x.getTime()), a = g.dateFormat(h.dateFormat, b.x)) : a = d.categories ? m(d.names[b.x], d.categories[b.x], b.x) : b.x);
                        b.splice(y, 0, a)
                    });
                return p = p.concat(e)
            };
        a.Chart.prototype.getCSV = function(a) {
            var f = "",
                h = this.getDataRows(),
                d = this.options.exporting.csv,
                l = m(d.decimalPoint, "," !== d.itemDelimiter && a ? (1.1).toLocaleString()[1] :
                    "."),
                e = m(d.itemDelimiter, "," === l ? ";" : ","),
                n = d.lineDelimiter;
            c(h, function(a, d) {
                for (var c, g = a.length; g--;) c = a[g], "string" === typeof c && (c = '"' + c + '"'), "number" === typeof c && "." !== l && (c = c.toString().replace(".", l)), a[g] = c;
                f += a.join(e);
                d < h.length - 1 && (f += n)
            });
            return f
        };
        a.Chart.prototype.getTable = function(a) {
            var f = "\x3ctable\x3e",
                h = this.options,
                d = a ? (1.1).toLocaleString()[1] : ".",
                l = m(h.exporting.useMultiLevelHeaders, !0);
            a = this.getDataRows(l);
            var e = 0,
                n = l ? a.shift() : null,
                p = a.shift(),
                q = function(a, c, f, l) {
                    var k = m(l,
                        "");
                    c = "text" + (c ? " " + c : "");
                    "number" === typeof k ? (k = k.toString(), "," === d && (k = k.replace(".", d)), c = "number") : l || (c = "empty");
                    return "\x3c" + a + (f ? " " + f : "") + ' class\x3d"' + c + '"\x3e' + k + "\x3c/" + a + "\x3e"
                };
            !1 !== h.exporting.tableCaption && (f += '\x3ccaption class\x3d"highcharts-table-caption"\x3e' + m(h.exporting.tableCaption, h.title.text ? h.title.text.replace(/&/g, "\x26amp;").replace(/</g, "\x26lt;").replace(/>/g, "\x26gt;").replace(/"/g, "\x26quot;").replace(/'/g, "\x26#x27;").replace(/\//g, "\x26#x2F;") : "Chart") + "\x3c/caption\x3e");
            for (var v = 0, u = a.length; v < u; ++v) a[v].length > e && (e = a[v].length);
            f += function(a, d, c) {
                var f = "\x3cthead\x3e",
                    e = 0;
                c = c || d && d.length;
                var k, b, g = 0;
                if (b = l && a && d) {
                    a: if (b = a.length, d.length === b) {
                        for (; b--;)
                            if (a[b] !== d[b]) {
                                b = !1;
                                break a
                            }
                        b = !0
                    } else b = !1;b = !b
                }
                if (b) {
                    for (f += "\x3ctr\x3e"; e < c; ++e) b = a[e], k = a[e + 1], b === k ? ++g : g ? (f += q("th", "highcharts-table-topheading", 'scope\x3d"col" colspan\x3d"' + (g + 1) + '"', b), g = 0) : (b === d[e] ? h.exporting.useRowspanHeaders ? (k = 2, delete d[e]) : (k = 1, d[e] = "") : k = 1, f += q("th", "highcharts-table-topheading",
                        'scope\x3d"col"' + (1 < k ? ' valign\x3d"top" rowspan\x3d"' + k + '"' : ""), b));
                    f += "\x3c/tr\x3e"
                }
                if (d) {
                    f += "\x3ctr\x3e";
                    e = 0;
                    for (c = d.length; e < c; ++e) void 0 !== d[e] && (f += q("th", null, 'scope\x3d"col"', d[e]));
                    f += "\x3c/tr\x3e"
                }
                return f + "\x3c/thead\x3e"
            }(n, p, Math.max(e, p.length));
            f += "\x3ctbody\x3e";
            c(a, function(a) {
                f += "\x3ctr\x3e";
                for (var d = 0; d < e; d++) f += q(d ? "td" : "th", null, d ? "" : 'scope\x3d"row"', a[d]);
                f += "\x3c/tr\x3e"
            });
            return f += "\x3c/tbody\x3e\x3c/table\x3e"
        };
        a.Chart.prototype.fileDownload = function(c, g, h) {
            var d;
            d = this.options.exporting.filename ?
                this.options.exporting.filename : this.title && this.title.textStr ? this.title.textStr.replace(/ /g, "-").toLowerCase() : "chart";
            u.Blob && u.navigator.msSaveOrOpenBlob ? (c = new u.Blob(["\ufeff" + h], {
                type: "text/csv"
            }), u.navigator.msSaveOrOpenBlob(c, d + "." + g)) : q ? (h = e.createElement("a"), h.href = c, h.download = d + "." + g, this.container.appendChild(h), h.click(), h.remove()) : a.error("The browser doesn't support downloading files")
        };
        a.Chart.prototype.downloadCSV = function() {
            var a = this.getCSV(!0);
            this.fileDownload("data:text/csv,\ufeff" +
                encodeURIComponent(a), "csv", a, "text/csv")
        };
        a.Chart.prototype.downloadXLS = function() {
            var a = '\x3chtml xmlns:o\x3d"urn:schemas-microsoft-com:office:office" xmlns:x\x3d"urn:schemas-microsoft-com:office:excel" xmlns\x3d"http://www.w3.org/TR/REC-html40"\x3e\x3chead\x3e\x3c!--[if gte mso 9]\x3e\x3cxml\x3e\x3cx:ExcelWorkbook\x3e\x3cx:ExcelWorksheets\x3e\x3cx:ExcelWorksheet\x3e\x3cx:Name\x3eArk1\x3c/x:Name\x3e\x3cx:WorksheetOptions\x3e\x3cx:DisplayGridlines/\x3e\x3c/x:WorksheetOptions\x3e\x3c/x:ExcelWorksheet\x3e\x3c/x:ExcelWorksheets\x3e\x3c/x:ExcelWorkbook\x3e\x3c/xml\x3e\x3c![endif]--\x3e\x3cstyle\x3etd{border:none;font-family: Calibri, sans-serif;} .number{mso-number-format:"0.00";} .text{ mso-number-format:"@";}\x3c/style\x3e\x3cmeta name\x3dProgId content\x3dExcel.Sheet\x3e\x3cmeta charset\x3dUTF-8\x3e\x3c/head\x3e\x3cbody\x3e' +
                this.getTable(!0) + "\x3c/body\x3e\x3c/html\x3e";
            this.fileDownload("data:application/vnd.ms-excel;base64," + u.btoa(unescape(encodeURIComponent(a))), "xls", a, "application/vnd.ms-excel")
        };
        a.Chart.prototype.viewData = function() {
            this.dataTableDiv || (this.dataTableDiv = e.createElement("div"), this.dataTableDiv.className = "highcharts-data-table", this.renderTo.parentNode.insertBefore(this.dataTableDiv, this.renderTo.nextSibling));
            this.dataTableDiv.innerHTML = this.getTable()
        };
        /*a.Chart.prototype.openInCloud = function() {
            function c(d) {
                Object.keys(d).forEach(function(e) {
                    "function" ===
                    typeof d[e] && delete d[e];
                    a.isObject(d[e]) && c(d[e])
                })
            }
            var g, h;
            g = a.merge(this.userOptions);
            c(g);
            g = {
                name: g.title && g.title.text || "Chart title",
                options: g,
                settings: {
                    constructor: "Chart",
                    dataProvider: {
                        csv: this.getCSV()
                    }
                }
            };
            h = JSON.stringify(g);
            (function() {
                var a = e.createElement("form");
                e.body.appendChild(a);
                a.method = "post";
                a.action = "https://cloud-api.highcharts.com/openincloud";
                a.target = "_blank";
                var c = e.createElement("input");
                c.type = "hidden";
                c.name = "chart";
                c.value = h;
                a.appendChild(c);
                a.submit();
                e.body.removeChild(a)
            })()
        };*/
        var C = a.getOptions().exporting;
        C && (a.extend(C.menuItemDefinitions, {
            downloadCSV: {
                textKey: "downloadCSV",
                onclick: function() {
                    this.downloadCSV()
                }
            },
            downloadXLS: {
                textKey: "downloadXLS",
                onclick: function() {
                    this.downloadXLS()
                }
            },
            viewData: {
                textKey: "viewData",
                onclick: function() {
                    this.viewData()
                }
            },
            /*openInCloud: {
                textKey: "openInCloud",
                onclick: function() {
                    this.openInCloud()
                }
            }*/
        }), C.buttons.contextButton.menuItems.push("separator", "downloadCSV", "downloadXLS", "viewData"));
        //C.buttons.contextButton.menuItems.push("separator", "downloadCSV", "downloadXLS", "viewData", "openInCloud"));
        n.map && (n.map.prototype.exportKey = "name");
        n.mapbubble && (n.mapbubble.prototype.exportKey = "name");
        n.treemap && (n.treemap.prototype.exportKey = "name")
    })(q)
});
