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

// FIXME(thacuber2a03): yayyyyyy repeated code

func WalkStatements(v Visitor, n []Statement) Visitor {
	for _, nn := range n {
		if v = v.Visit(nn); v == nil {
			return nil
		}
	}
	return v
}

func WalkDeclarations(v Visitor, n []Declaration) Visitor {
	for _, nn := range n {
		if v = v.Visit(nn); v == nil {
			return nil
		}
	}
	return v
}
