# Scraper created by Edward

def get_specifes_info():
    results = []
    website = requests.get(WIKIPEDIA_SRC)
    soup = BeautifulSoup(website.text, 'html.parser')
    # body = soup.find('div', {'class': 'div-col'})

    list_of_bird_pages = soup.find_all('div', {'class': 'div-col'})
    for body in list_of_bird_pages:
        bird_list = body.find_all('li')

        for b in bird_list:
            common_name = b.get_text()
            species_site = requests.get(WIKIPEDIA + "wiki/" + common_name.replace("'s", "%27s").replace(' ', '_'))
            species_soup = BeautifulSoup(species_site.text, 'html.parser')
            species_body = species_soup.find('div', {'class': 'mw-parser-output'})
            list_of_p_tags = species_body.find_all('p')
            if len(list_of_p_tags) > 4:
                species_description = list_of_p_tags[4].get_text()
            else:
                species_description = "No description"
            image_body = species_body.find('a', {'class': 'image'})
            if image_body is not None:
                image_soup = image_body.find('img')
                common_image_link = image_soup['src'].replace('//upload', 'upload')
            else:
                common_image_link = "No image src"
            results.append({
                'Bird Species': common_name.strip(),
                'Image link': common_image_link.strip(),
                'Description': species_description.strip()
            })
            print("Bird species: " + common_name + " parsed")
    return results