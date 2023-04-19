function Register()

    module.Name = 'Kemono'
    module.Adult = true
    module.Type = 'artist cg'
    module.Strict = false

    module.Domains.Add('kemono.party')

end

function GetInfo()

    info.Title = dom.SelectValue('//h1')

    if(url:contains('/post/')) then

        info.Artist = dom.SelectValue('//a[contains(@class,"post__user-name")]')
        info.PageCount = GetAttachmentsAndFiles().Count()

    else

        info.Artist = info.Title
        info.ChapterCount = dom.SelectValue('//div[contains(@class,"paginator")]//small'):after('of')

    end

end

function GetChapters()

    -- Make sure we're on the first page of posts.

    url = SetParameter(url, 'o', '0')
    dom = Dom.New(http.Get(url))

    for page in Paginator.New(http, dom, '//div[contains(@class,"paginator")]//a[contains(@class,"next")]/@href') do
    
        local postCards = page.SelectElements('//article[contains(@class,"post-card")]')

        for i = 0, postCards.Count() - 1 do

            local postCard = postCards[i]
            local postUrl = postCard.SelectValue('./a/@href')
            local postTitle = postCard.SelectValue('.//header')

            chapters.Add(postUrl, postTitle)

        end

    end

    chapters.Reverse()

end

function GetPages()

    pages.AddRange(GetAttachmentsAndFiles())

end

function GetAttachmentsAndFiles()

    -- Some posts display the same file twice, so make sure we only download it once.

    local items = List.New()

    for item in dom.SelectValues('//li[contains(@class,"post__attachment")]//@href') do

        if(not items.Contains(item)) then

            items.Add(item)

        end

    end

    for item in dom.SelectValues('//div[contains(@class,"post__thumbnail")]//@href') do

        if(not items.Contains(item)) then

            items.Add(item)

        end

    end

    return items

end