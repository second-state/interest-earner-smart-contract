# pip3 install pandas
# pip3 install numpy
# pip3 install jinja2

# To run
# python3 report.py serialized_file_generated_by_send_tokens.py

import sys
import jinja2
import pickle
import numpy as np
import pandas as pd
import configparser

# Read the config
config = configparser.ConfigParser()
config.read('config.ini')
explorerAddress = config['explorer']['address']
explorerTransaction = config['explorer']['transaction']

n = len(sys.argv)
if n == 2:
    serialized_file = sys.argv[1]
    # Open serialized file
    with open(serialized_file, 'rb') as f:
        list_array = pickle.load(f)
    formatted_list_array = []
    for list_item in list_array:
        temp_tx_url = '''<a href="''' + explorerTransaction + str(list_item[2]) + '''" target="_blank">''' + list_item[2] + '''</a>'''
        temp_address_url = '''<a href="''' + explorerAddress + str(list_item[0]) + '''" target="_blank">''' + list_item[0] + '''</a>'''
        formatted_list_array.append([temp_address_url, list_item[1], temp_tx_url])
    index_data = []
    for item in list_array:
        temp_string =  str(item[0])
        cut_string = temp_string[:6] + "..." + temp_string[-6:]
        index_data.append(cut_string)

    # Sample DataFrame
    df = pd.DataFrame(formatted_list_array, columns=['Address', 'Amount', 'Transaction_Hash'], index=index_data)

    def color_black(val):
        color = 'black'
        return f'color: {color}'

    styler = df.style.applymap(color_black)

    # Template handling
    env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=''))
    template = env.get_template('template.html')
    html = template.render(my_table=styler.render())

    # Write the HTML file
    with open('report_transfers.html', 'w') as f:
        f.write(html)
else:
    print("Please run this script with an argument (which points to the serialized file) i.e. python3 report.py 2021-06-24-09-36-00")
