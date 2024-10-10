package ast

// Interface for types that want to traverse AST nodes.
// This interface mirrors the one in go/ast/walk.go in
// Go's source code.
type Visitor interface {
	Visit(n Node) (w Visitor)
}

// TODO(thacuber2a03): I can't tell what the Go team
// wanted to do by returning a visitor... is it supposed
// to be a quick escape route?
