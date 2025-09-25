#include <ostream>
#include <stdexcept>
#include <string>

#include <emscripten.h>

#include <common/mapping.h>
#include <chp/graph.h>
#include <chp/synthesize.h>
#include <common/standard.h>
#include <flow/func.h>
#include <flow/module.h>
#include <flow/synthesize.h>
#include <interpret_chp/import_chp.h>
#include <interpret_chp/import_cog.h>
#include <interpret_chp/export_dot.h>
#include <interpret_flow/export_dot.h>
#include <interpret_flow/export_verilog.h>
#include <parse/tokenizer.h>
#include <parse/default/block_comment.h>
#include <parse/default/line_comment.h>
#include <parse_cog/composition.h>
#include <parse_cog/branch.h>
#include <parse_cog/control.h>
#include <parse_cog/factory.h>
#include <petri/graph.h>

//#include "dot.h"

//const int WIDTH = 8;

chp::graph importCHPFromCogString(const string &cog) {
	tokenizer tokens;
	tokens.register_token<parse::block_comment>(false);
	tokens.register_token<parse::line_comment>(false);
	parse_cog::register_syntax(tokens);

	tokens.insert("string_input", cog, nullptr);
	chp::graph g;

	tokens.increment(false);
	tokens.expect<parse_cog::composition>();
	if (tokens.decrement(__FILE__, __LINE__)) {
		parse_cog::composition syntax(tokens);
		//cout << "===>" << syntax.to_string() << endl;  // for debugging parse vs interpret
		chp::import_chp(g, syntax, &tokens, true);
	}

	return g;
}



std::string render_weaver(const std::string &raw_user_input) {

    // Atempt to parse COG from raw user input
    chp::graph g = importCHPFromCogString(raw_user_input);
    g.name = "slop";
    string chpRawDot = chp::export_graph(g, true).to_string();
		//gvdot::render("chp_slop.png", chpRawDot);
    
    // Attempt to canonicalize graph
    g.post_process(true, false);
    g.flatten();
		g.name = "slop_but_in_a_fancy_canonical_suit";
    string chpCanonicalDot = chp::export_graph(g, true).to_string();
		//gvdot::render("chp_canonical_slop.png", chpCanonicalDot);
    
    // Lower to Flow
    flow::Func f = chp::synthesizeFuncFromCHP(g);
		f.name = "slop";
    std::cout << f << std::endl;
    string flowDot = flow::export_func(f, false).to_string();
    
    // Lower to Verilog
		clocked::Module mod = synthesizeModuleFromFunc(f);
		parse_verilog::module_def mod_v = flow::export_module(mod);
		string verilog = mod_v.to_string();

    // Bundle 4 dialects into 1 packet
    return chpRawDot
			+ "\n---\n" + chpCanonicalDot
			+ "\n---\n" + flowDot
			+ "\n---\n" + verilog;
}



extern "C" {
	EMSCRIPTEN_KEEPALIVE
		void init() {
			emscripten_run_script("console.log('WebAssembly module initialized')");
		}

	EMSCRIPTEN_KEEPALIVE
		char* processLoomCode(const char* raw_user_input) {
			try {
				std::string result = render_weaver(std::string(raw_user_input));
				
				// Allocate memory for the result string in the WebAssembly module
				char* output = (char*)malloc(result.length() + 1);
				if (!output) {
					return nullptr; // Memory allocation failed
				}
				
				// Copy the result to the allocated memory
				std::strcpy(output, result.c_str());
				return output;
			} catch (const std::exception& e) {
				// Handle any C++ exceptions
				const char* error = e.what();
				char* error_output = (char*)malloc(strlen(error) + 1);
				if (error_output) {
					std::strcpy(error_output, error);
				}
				return error_output;
			} catch (...) {
				// Handle any other exceptions
				const char* error = "Unknown error occurred";
				char* error_output = (char*)malloc(strlen(error) + 1);
				if (error_output) {
					std::strcpy(error_output, error);
				}
				return error_output;
			}
		}
}
