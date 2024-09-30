from flask import Flask, request, render_template
import subprocess
import logging

app = Flask(__name__)

logging.basicConfig(level=logging.DEBUG)

MODEL_PATHS = {
    "Llama3-8b": "/Users/benvin-18053/Desktop/CodeVerse/llm/model/Llama3-8b-q4",
    "Mistral-7B-Instruct-v0.2": "/Users/benvin-18053/Desktop/CodeVerse/llm/model/Mistral-7B-Instruct-v0.2-q4",
}

@app.route('/')
def index():
    return render_template('index.html', model_paths=MODEL_PATHS)

@app.route('/run_model', methods=['POST'])
def run_model():
    model_name = request.form.get('model_path')
    model_path = MODEL_PATHS[model_name] 
    prompt = request.form.get('prompt')
    max_tokens = request.form.get('max_tokens', type=int)
    temp = request.form.get('temp', type=float)
    top_p = request.form.get('top_p', type=float)
    verbose = request.form.get('verbose') == 'on' 


    command = [
        'python', '/Users/benvin-18053/Desktop/CodeVerse/llm/PythonServer/FlashServer/generate.py', 
        '--model', model_path,
        '--prompt', prompt,
        '--max-tokens', str(max_tokens),
        '--temp', str(temp),
        '--top-p', str(top_p),
    ]
    if verbose:
        command.append('--verbose')
        
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        logging.info("\n"+"\n"+"\n"+"\n"+prompt+"\n"+"\n"+"\n"+"\n")
        response = result.stdout
    except subprocess.CalledProcessError as e:
        logging.error(f"Error running model: {e.stderr}")
        response = f"Error: {e.stderr}"

    return render_template('index.html', response=response, model_paths=MODEL_PATHS)

if __name__ == '__main__':
    app.run(debug=True)