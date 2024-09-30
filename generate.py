import argparse
from mlx_lm import generate, load

def main():
    parser = argparse.ArgumentParser(description="LLM inference script")
    parser.add_argument("--model", type=str, required=True, help="Path to the model checkpoint")
    parser.add_argument("--prompt", type=str, required=True, help="Prompt for the model")
    parser.add_argument("--max-tokens", type=int, default=1000, help="Maximum number of tokens to generate")
    parser.add_argument("--temp", type=float, default=0.7, help="Sampling temperature")
    parser.add_argument("--top-p", type=float, default=0.95, help="Sampling top-p")
    parser.add_argument("--seed", type=int, default=0, help="PRNG seed")
    parser.add_argument("--verbose", action='store_true', help="Enable verbose output")
    
    args = parser.parse_args()
    model, tokenizer = load(path_or_hf_repo=args.model)
    conversation = [{"role": "user", "content": args.prompt}]
    prompt = tokenizer.apply_chat_template(
        conversation=conversation, tokenize=False, add_generation_prompt=True
    )

    generation_args = {
        "temp": args.temp,
        "repetition_penalty": 1.2,
        "repetition_context_size": 20,
        "top_p": args.top_p,
    }

    response = generate(
        model=model,
        tokenizer=tokenizer,
        prompt=prompt,
        max_tokens=args.max_tokens,
        verbose=args.verbose,
        **generation_args,
    )

    print(response)  

if __name__ == "__main__":
    main()